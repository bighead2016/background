-module(util_background).

-include("log.hrl").
-include("account.hrl").
-include("background.hrl").
-include("log_type.hrl").

-compile(export_all).

%% 将请求的二进制内容转换为字符串
http_content_to_list(HttpContentList) ->
	F = fun({Key, Val}) ->
			{erlang:binary_to_list(Key), erlang:binary_to_list(Val)}
		end,
	lists:map(F, HttpContentList).

%% 检查TICK值
check_tick(TickList) ->
	F = fun({Key, Val1}, BinStr) ->
			case Key == <<"flag">> of
				true ->
					BinStr;
				false ->
					Val = list_to_binary(urlencode(binary_to_list(Val1))),
					% Val = list_to_binary(http_uri:encode(binary_to_list(Val1))),
					<<BinStr/binary, Key/binary, Val/binary>>
			end
		end,
	ServerTickStr1 = lists:foldl(F, <<>>, TickList),
	{ok, ServerKey} = application:get_env(background, background_key), %?SERVER_KEY,
	ServerTickStr = util:md5(<<ServerTickStr1/binary, ServerKey/binary>>),
	{_, ClientTickStr} = lists:keyfind(<<"flag">>, 1, TickList),

	?ERR(?MODULE, "OriString = ~p", [<<ServerTickStr1/binary, ServerKey/binary>>]),
	?ERR(?MODULE, "ServerTickStr=~p, ClientTickStr=~p", [string:to_upper(ServerTickStr), binary_to_list(ClientTickStr)]),

	string:to_upper(ServerTickStr) == string:to_upper(binary_to_list(ClientTickStr)).

%% 台湾7725
check_recharge_sign_4_twand_7725(TickList) ->
	F = fun({Key, Val}, BinStr) ->
		case Key of
			<<"sign">> ->
				BinStr;
			_ ->
				Val1 = list_to_binary(http_uri:decode(binary_to_list(Val))),
				<<BinStr/binary, Key/binary, $=:8, Val1/binary>>
		end
	end,
	ServerTickStr1 = lists:foldl(F, <<>>, TickList),

 	#platform{ recharge_key= ServerKey } = util_config:get_platform_info(?PF_TWAND_7725),

    ServerTickStr = util:md5(<<ServerTickStr1/binary, ServerKey/binary>>),
	{_, ClientTickStr} = lists:keyfind(<<"sign">>, 1, TickList),

	case string:to_upper(ServerTickStr) == string:to_upper(binary_to_list(ClientTickStr)) of
		true ->
			true;
		false ->
			?ERR(?MODULE, "OriServerStr = ~s", [<<ServerTickStr1/binary, ServerKey/binary>>]),
			{false, string:to_upper(binary_to_list(ClientTickStr)), string:to_upper(ServerTickStr)}
	end.

%% anysdk
check_recharge_sign_4_anysdk(TickList) ->
	F = fun({Key, Val}, BinStr) ->
		case Key of
			<<"sign">> ->
				BinStr;
			% <<"enhanced_sign">> ->
			% 	BinStr;
			_ ->
				<<BinStr/binary, Val/binary>>
		end
	end,
	ServerTickStr1 = lists:foldl(F, <<>>, TickList),

 	% #platform{ recharge_key= ServerKey } = util_config:get_platform_info(?PF_TWAND_7725),

 	ServerKey = "F3666F5DEB0B41260D7BD269C6728ECD",

 	Params = util:md5(ServerTickStr1),

    ServerTickStr = util:md5(string:to_lower(Params) ++ ServerKey),

	{_, ClientTickStr} = lists:keyfind(<<"sign">>, 1, TickList),

	case string:to_upper(ServerTickStr) == string:to_upper(binary_to_list(ClientTickStr)) of
		true ->
			true;
		false ->
			?ERR(?MODULE, "OriServerStr = ~s", [<<ServerTickStr1/binary, (list_to_binary(ServerKey))/binary>>]),
			{false, string:to_upper(binary_to_list(ClientTickStr)), string:to_upper(ServerTickStr)}
	end.

check_recharge_sign_4_yyios_pp(DataStr) ->
	%% 获取RSA public key
    #platform{ recharge_key= RSAPubKey } = util_config:get_platform_info(?PF_IOS_PP),
	%% RSA 公钥解密
	DecryptBin = public_key:decrypt_public(base64:decode(DataStr), RSAPubKey),
	mochijson2:decode(DecryptBin).

%% 二进制字符串转换成整型
bitstring_to_integer(<<>>) ->
	0;
bitstring_to_integer(Int) when is_integer(Int) ->
	Int;
bitstring_to_integer(BinStr) ->
	case (catch list_to_integer(binary_to_list(BinStr))) of
		Value when is_integer(Value) ->
			Value;
		_ ->
			-1
	end.

%% [1,2,3] -> "'1','2','3'".
list_to_string(List) ->
	list_to_string(List, "").

list_to_string([Element|Rest], ResultStr) ->
	case is_list(Element) of
		true ->
			NewResultStr = lists:flatten(io_lib:format("~s,'~ts'", [ResultStr,Element]));
		false ->
			NewResultStr = lists:flatten(io_lib:format("~s,~p", [ResultStr,Element]))
	end,
	list_to_string(Rest, NewResultStr);
list_to_string([], "") ->
	"";
list_to_string([], ResultStr) ->
	string:sub_string(ResultStr, 2, length(ResultStr)).

bitstring_to_term(<<>>) ->
	[];
bitstring_to_term(BitString) ->
	string_to_term(binary_to_list(BitString)).

%% term反序列化，string转换为term，e.g., "[{a},1]"  => [{a},1]
string_to_term(String) ->
    case erl_scan:string(String++".") of
        {ok, Tokens, _} ->
            case erl_parse:parse_term(Tokens) of
                {ok, Term} -> Term;
                _Err -> undefined
            end;
        _Error ->
            undefined
    end.

get_account_info_by_id(AccountID) ->
	case catch mod_account:lookup_account(AccountID) of
		AccountRec when is_record(AccountRec, account) ->
			AccountRec;
		_ ->
			none
	end.

get_account_info_by_account(Account, ServerID) ->
	case catch mod_account:lookup_account(Account, ServerID) of
		AccountRec when is_record(AccountRec, account) ->
			AccountRec;
		_ ->
			none
	end.

%% <<"abc, def, ghi">> -> [<<"abc">>, <<"def">>, <<"ghi">>]
get_string_list(NameListStr) ->
	NameList = string:tokens(binary_to_list(NameListStr), ","),
	[list_to_binary(Name) || Name<-NameList].

%% %% <<"1, 2, 3">> -> [1, 2, 3].
get_integer_list(IntListStr) ->
	IntList = string:tokens(binary_to_list(IntListStr), ","),
	[list_to_integer(Int) || Int<-IntList].

%% <<"abc, def">> -> "\"abc\",\"def\"".
bitstring_to_sql_string(String) ->
	list_to_string(string:tokens(binary_to_list(String), ",")).

urlencode([C | Cs]) when C >= $a, C =< $z ->
    [C | urlencode(Cs)];
urlencode([C | Cs]) when C >= $A, C =< $Z ->
    [C | urlencode(Cs)];
urlencode([C | Cs]) when C >= $0, C =< $9 ->
    [C | urlencode(Cs)];
urlencode([C = $. | Cs]) ->
    [C | urlencode(Cs)];
urlencode([C = $- | Cs]) ->
    [C | urlencode(Cs)];
urlencode([C = $_ | Cs]) ->
    [C | urlencode(Cs)];
urlencode([C | _Cs]) when C > 16#ff ->
    error(badarg);
urlencode([C | Cs]) ->
    escape_byte(C) ++ urlencode(Cs);
urlencode([]) ->
    [].

escape_byte(C) when C >= 0, C =< 255 ->
    [$%, string:to_upper(hex_digit(C bsr 4)), string:to_upper(hex_digit(C band 15))].

hex_digit(N) when N >= 0, N =< 9 ->
    N + $0;
hex_digit(N) when N > 9, N =< 15 ->
    N + $a - 10.


urlencode1([C | Cs]) when C >= $a, C =< $z ->
    [C | urlencode1(Cs)];
urlencode1([C | Cs]) when C >= $A, C =< $Z ->
    [C | urlencode1(Cs)];
urlencode1([C | Cs]) when C >= $0, C =< $9 ->
    [C | urlencode1(Cs)];
urlencode1([C = $. | Cs]) ->
    [C | urlencode1(Cs)];
urlencode1([C = $- | Cs]) ->
    [C | urlencode1(Cs)];
urlencode1([C = $_ | Cs]) ->
    [C | urlencode1(Cs)];
urlencode1([C | _Cs]) when C > 16#ff ->
    error(badarg);
urlencode1([C | Cs]) ->
    escape_byte1(C) ++ urlencode1(Cs);
urlencode1([]) ->
    [].

escape_byte1(C) when C >= 0, C =< 255 ->
    [$%, hex_digit(C bsr 4), hex_digit(C band 15)].




% check_tick_4_4399_plat(Type, TickList) ->
% 	F = fun({Key, Val1}, BinStr) ->
% 			case Key == <<"flag">> of
% 				true ->
% 					BinStr;
% 				false ->
% 					Val = list_to_binary(urlencode(binary_to_list(Val1))),
% 					<<BinStr/binary, Val/binary>>
% 			end
% 		end,
% 	ServerTickStr1 = lists:foldl(F, <<>>, TickList),
% 	%%{ok, ServerKey} = 
% 	%%case Type of
% 	%%	pay ->
% 	%%		application:get_env(background, background_key);
% 	%%	_ ->
% 	%%		{ok, ServerKey1} = application:get_env(oceanus, server_key),
% 	%%		{ok, list_to_binary(ServerKey1)}
% 	%%end,
% 	PlatformLoginList = util_oceanus:get_platform_login_list(),
%     {_, _, _, _, ServerKey1} = lists:keyfind(?PF_NEW_4399, 1, PlatformLoginList),
%     ServerKey = list_to_binary(ServerKey1),
% 	ServerTickStr = util:md5(<<ServerTickStr1/binary, ServerKey/binary>>),
% 	{_, ClientTickStr} = lists:keyfind(<<"flag">>, 1, TickList),

% 	?ERR(background, "ServerTickStr=~p, ClientTickStr=~p", [string:to_upper(ServerTickStr), string:to_upper(binary_to_list(ClientTickStr))]),

% 	string:to_upper(ServerTickStr) == string:to_upper(binary_to_list(ClientTickStr)).

% check_tick_4_91(PlatformId, TickList) ->
% 	F = fun({Key, Val1}, BinStr) ->
% 		case Key of
% 			<<"Sign">> ->
% 				BinStr;
% 			_ ->
% 				Val2 = binary_to_list(Val1),

% 				Val = list_to_binary(http_uri:decode(Val2)),
% 				<<BinStr/binary, Val/binary>>
% 		end
% 	end,
% 	ServerTickStr1 = lists:foldl(F, <<>>, TickList),
% 	% {ok, PlatformLoginList} = application:get_env(ranch, platform_login_list),
% 	PlatformLoginList = util_oceanus:get_platform_login_list(),
%     {_, _, _AppID, _HttpAddr, ServerKey1} = lists:keyfind(PlatformId, 1, PlatformLoginList),
%     ServerKey = list_to_binary(ServerKey1),
%     ServerTickStr = util:md5(<<ServerTickStr1/binary, ServerKey/binary>>),
% 	{_, ClientTickStr} = lists:keyfind(<<"Sign">>, 1, TickList),

% 	?DBG(background, "ServerTickStr1 = ~s", [binary_to_list(ServerTickStr1)]),

% 	?DBG(background, "ServerTickStr=~p, ClientTickStr=~p", [string:to_upper(ServerTickStr), string:to_upper(binary_to_list(ClientTickStr))]),
% 	string:to_upper(ServerTickStr) == string:to_upper(binary_to_list(ClientTickStr)).


% check_tick_4_card(TickList, Flag) ->
% 	F = fun(Val1, BinStr) ->
% 			Val = list_to_binary(urlencode(binary_to_list(Val1))),
% 			<<BinStr/binary, Val/binary>>
% 	end,
% 	ServerTickStr1 = lists:foldl(F, <<>>, TickList),
% 	{ok, ServerKey} = application:get_env(background, background_key), %?SERVER_KEY,
% 	ServerTickStr = util:md5(<<ServerTickStr1/binary, ServerKey/binary>>),
% 	{_, ClientTickStr} = lists:keyfind(<<"flag">>, 1, TickList),

% 	% ?DBG(background, "ServerTickStr=~p, ClientTickStr=~p", [string:to_upper(ServerTickStr), string:to_upper(binary_to_list(ClientTickStr))]),

% 	string:to_upper(ServerTickStr) == string:to_upper(binary_to_list(ClientTickStr)).

% check_tick_4_ky(ArgList) ->
% 	F = fun({Key, Val1}, BinStr) ->
% 		case Key == <<"sign">> of
% 				true ->
% 					BinStr;
% 				false ->

% 					Val2 = binary_to_list(Val1),

% 					Val = list_to_binary(http_uri:decode(Val2)),

% 					KLen = byte_size(Key),
% 					case BinStr of
% 						<<>> ->
% 							<<BinStr/binary, Key:KLen/binary-unit:8, $=:8, Val/binary>>;
% 						_ ->
% 							Len = byte_size(BinStr),
% 							<<BinStr:Len/binary-unit:8, $&:8, Key:KLen/binary-unit:8, $=:8, Val/binary>>
% 					end
% 			end
% 	end,
% 	UrlArgBinStr = lists:foldl(F, <<>>, ArgList),
% 	{_, SignStr1} = lists:keyfind(<<"sign">>, 1, ArgList),
% 	SignStr = base64:decode(SignStr1),

% 	?DBG(background, "SignStr1 = ~s", [SignStr1]),

% 	?DBG(background, "SignStr = ~s", [SignStr]),

% 	%% 获取RSA public key
% 	PublicKey=get_public_key(?PF_KY),
% 	%% 验证签名

% 	?DBG(background, "UrlArgBinStr = ~s", [UrlArgBinStr]),

% 	public_key:verify(UrlArgBinStr, 'sha', SignStr, PublicKey),

% 	true.

% public_decode_4_ky(NotifyDataStr) ->
% 	%% 获取RSA public key
% 	RSAPubKey=get_public_key(?PF_KY),
% 	%% RSA 公钥解密
% 	DecryptBin = public_key:decrypt_public(base64:decode(NotifyDataStr), RSAPubKey),
% 	DecryptStr1 = binary_to_list(DecryptBin),
% 	DecryptStr = string:tokens(DecryptStr1, "&"),
% 	F = fun(Str) ->
% 		[KeyStr, ValStr] = string:tokens(Str, "="),
% 		{list_to_binary(KeyStr), list_to_binary(ValStr)}
% 	end,
% 	lists:map(F, DecryptStr).

% public_decode_4_json(NotifyDataStr) ->
% 	%% 获取RSA public key
% 	RSAPubKey=get_public_key(?PF_PP),
% 	%% RSA 公钥解密
% 	DecryptBin = public_key:decrypt_public(base64:decode(NotifyDataStr), RSAPubKey),
% 	{struct, List} = mochijson2:decode(DecryptBin),
% 	List.

% get_public_key(PlatformID) ->
% 	FileName = 
% 	case PlatformID of
% 		?PF_PP ->
% 			"etc/keys/pp_key.pub";
% 		?PF_KY ->
% 			"etc/keys/ky_key.pub";
% 		?PF_ITOOLS ->
% 			"etc/keys/itools_key.pub";
% 		?PF_FEILIU ->
% 			"etc/keys/feiliu_key.pub";
% 		?PF_PAOJIAO ->
% 			"etc/keys/paojiao_key.pub";
% 		?PF_HUAWEI ->
% 			"etc/keys/huawei_key.pub"
% 	end,

% 	% RSAKeyList = application:get_env(background, rsa_key_list),
% 	% {ok, PublicKey, _PrivateKey} = lists:keyfind(PlatformID, 1, RSAKeyList),

% 	{ok, PublicKey} = file:read_file(FileName),

% 	?DBG(background, "PublicKey = ~p", [PublicKey]),

% 	%% 获取RSA public key
% 	PemEntries = public_key:pem_decode(PublicKey),
% 	public_key:pem_entry_decode(hd(PemEntries)).

% get_private_key(PlatformID) ->
% 	RSAKeyList = application:get_env(background, rsa_key_list),
% 	{ok, _PublicKey, PrivateKey} = lists:keyfind(PlatformID, 1, RSAKeyList),
% 	PrivateKey.

% %% 点金
% check_tick_4_mjoy(TickList) ->
% 	F = fun({Key, Val}, BinStr) ->
% 		case Key of
% 			<<"Sign">> ->
% 				BinStr;
% 			_ ->
% 				case BinStr of
% 					<<>> ->
% 						<<Key/binary, $=:8, Val/binary>>;
% 					_ ->
% 						<<BinStr/binary, $&:8, Key/binary, $=:8, Val/binary>>
% 				end
% 		end
% 	end,
% 	ServerTickStr1 = lists:foldl(F, <<>>, TickList),
% 	% {ok, PlatformLoginList} = application:get_env(ranch, platform_login_list),
% 	PlatformLoginList = util_oceanus:get_platform_login_list(),
%     {_, _, _AppID, _HttpAddr, ServerKey1} = lists:keyfind(?PF_DIANJIN, 1, PlatformLoginList),
%     ServerKey = list_to_binary(ServerKey1),
%     ServerTickStr = util:md5(<<ServerTickStr1/binary, ServerKey/binary>>),
% 	{_, ClientTickStr} = lists:keyfind(<<"Sign">>, 1, TickList),

% 	?DBG(background, "ServerTickStr1 = ~s", [binary_to_list(ServerTickStr1)]),
% 	?DBG(background, "ServerTickStr=~p, ClientTickStr=~p", [string:to_upper(ServerTickStr), string:to_upper(binary_to_list(ClientTickStr))]),
% 	string:to_upper(ServerTickStr) == string:to_upper(binary_to_list(ClientTickStr)).

% %% 当乐
% check_tick_4_dangle(TickList) ->
% 	F = fun({Key, Val}, BinStr) ->
% 		case Key of
% 			<<"signature">> ->
% 				BinStr;
% 			_ ->
% 				case BinStr of
% 					<<>> ->
% 						<<Key/binary, $=:8, Val/binary>>;
% 					_ ->
% 						<<BinStr/binary, $&:8, Key/binary, $=:8, Val/binary>>
% 				end
% 		end
% 	end,
% 	ServerTickStr1 = lists:foldl(F, <<>>, TickList),


%     {ok, ServerKey} = file:read_file("etc/keys/dl_key.pub"),
%     Field = <<"&key=">>,
%     ?DBG(background, "TickList = ~p", [TickList]),
%     ServerTickStr = util:md5(<<ServerTickStr1/binary, Field/binary,  ServerKey/binary>>),
% 	{_, ClientTickStr} = lists:keyfind(<<"signature">>, 1, TickList),

% 	?DBG(background, "ServerTickStr1 = ~s", [binary_to_list(<<ServerTickStr1/binary, Field/binary,  ServerKey/binary>>)]),
% 	?DBG(background, "ServerTickStr=~p, ClientTickStr=~p", [string:to_upper(ServerTickStr), string:to_upper(binary_to_list(ClientTickStr))]),
% 	string:to_upper(ServerTickStr) == string:to_upper(binary_to_list(ClientTickStr)).

% %% UC久游
% check_tick_4_uc(TickList) ->
% 	F = fun({Key, Val}, BinStr) ->
% 		case Key of
% 			<<"sign">> ->
% 				BinStr;
% 			_ ->
% 				<<BinStr/binary, Key/binary, $=:8, Val/binary>>
% 		end
% 	end,
% 	ServerTickStr1 = lists:foldl(F, <<>>, TickList),
% 	% {ok, PlatformLoginList} = application:get_env(ranch, platform_login_list),
% 	PlatformLoginList = util_oceanus:get_platform_login_list(),
%     {_, CPID1, _, _HttpAddr, ServerKey1} = lists:keyfind(?PF_UC, 1, PlatformLoginList),
%     ServerKey = list_to_binary(ServerKey1),
%     CPID = list_to_binary(CPID1),
%     ServerTickStr = util:md5(<<CPID/binary, ServerTickStr1/binary, ServerKey/binary>>),
% 	{_, ClientTickStr} = lists:keyfind(<<"sign">>, 1, TickList),

% 	?DBG(background, "ServerTickStr1 = ~s", [binary_to_list(ServerTickStr1)]),
% 	?DBG(background, "ServerTickStr=~p, ClientTickStr=~p", [string:to_upper(ServerTickStr), string:to_upper(binary_to_list(ClientTickStr))]),
% 	string:to_upper(ServerTickStr) == string:to_upper(binary_to_list(ClientTickStr)).

% check_tick_4_iapppay(TransData, SignStr, RSAPubKey) ->

% 	{ok, PHPExecPath} = application:get_env(oceanus, php_exec_path),

% 	PHPCmd = PHPExecPath ++ " php/check_key/check_tick_4_iapppay.php '" ++ binary_to_list(TransData) ++ "' '" ++ RSAPubKey ++ "' '" ++ binary_to_list(SignStr) ++ "'",
% 	?ERR(background, "PHPCmd = ~p", [PHPCmd]),

% 	case os:cmd(PHPCmd) of
% 		"SUCCESS" ->
% 			true;
% 		"FAILED" ->
% 			?ERR(background, "Other = FAILED"),
% 			false;
% 		Other ->
% 			?ERR(background, "Other = ~p", [Other]),
% 			false
% 	end.

% %% 同步
% check_tick_4_tb(TickList) ->
% 	F = fun({Key, Val1}, BinStr) ->
% 		case Key of
% 			<<"sign">> ->
% 				BinStr;
% 			_ ->
% 				Val2 = binary_to_list(Val1),

% 				Val = list_to_binary(http_uri:decode(Val2)),

% 				case BinStr of
% 					<<>> ->
% 						<<Key/binary, $=:8, Val/binary>>;
% 					_ ->
% 						<<BinStr/binary, $&:8, Key/binary, $=:8, Val/binary>>
% 				end
% 		end
% 	end,
% 	ServerTickStr1 = lists:foldl(F, <<>>, TickList),
% 	% {ok, PlatformLoginList} = application:get_env(ranch, platform_login_list),
% 	PlatformLoginList = util_oceanus:get_platform_login_list(),
%     {_, _CPID1, _, _HttpAddr, ServerKey1} = lists:keyfind(?PF_TB, 1, PlatformLoginList),
%     ServerKey = list_to_binary(ServerKey1),
%     Field = <<"&key=">>,
%     ?DBG(background, "TickList = ~p", [TickList]),
%     ServerTickStr = util:md5(<<ServerTickStr1/binary, Field/binary,  ServerKey/binary>>),
% 	{_, ClientTickStr} = lists:keyfind(<<"sign">>, 1, TickList),

% 	?DBG(background, "ServerTickStr1 = ~s", [binary_to_list(<<ServerTickStr1/binary, Field/binary,  ServerKey/binary>>)]),
% 	?DBG(background, "ServerTickStr=~p, ClientTickStr=~p", [string:to_upper(ServerTickStr), string:to_upper(binary_to_list(ClientTickStr))]),
% 	string:to_upper(ServerTickStr) == string:to_upper(binary_to_list(ClientTickStr)).

% %% itools
% public_decode_4_itools(NotifyDataStr) ->
% 		%% 获取RSA public key
% 	RSAPubKey=get_public_key(?PF_ITOOLS),
% 	%% RSA 公钥解密
% 	parse_list_for_itools(base64:decode(NotifyDataStr),RSAPubKey).

% parse_list_for_itools([], _RSAPubKey) ->
% 	[];
% parse_list_for_itools(List, RSAPubKey) when length(List) =< 128 ->
% 	DecryptBin = public_key:decrypt_public(List, RSAPubKey),
% 	binary_to_list(DecryptBin);
% parse_list_for_itools(List, RSAPubKey) ->
% 	{HList, TList} = lists:split(128, List),
% 	DecryptBin = public_key:decrypt_public(HList, RSAPubKey),
% 	RestList = parse_list_for_itools(TList, RSAPubKey),
% 	binary_to_list(DecryptBin) ++ RestList.

% check_tick_4_77app(TransData, SignStr, RSAPubKey) ->
% 	check_tick_4_iapppay(TransData, SignStr, RSAPubKey).

% check_tick_4_77app(TickList) ->
% 	F = fun({Key, Val1}, BinStr) ->
% 		case Key of
% 			<<"Sign">> ->
% 				BinStr;
% 			_ ->
% 				Val2 = binary_to_list(Val1),

% 				Val = list_to_binary(http_uri:decode(Val2)),
% 				<<BinStr/binary, Val/binary>>
% 		end
% 	end,
% 	ServerTickStr1 = lists:foldl(F, <<>>, TickList),
% 	% {ok, PlatformLoginList} = application:get_env(ranch, platform_login_list),
% 	PlatformLoginList = util_oceanus:get_platform_login_list(),
%     {_, _, _AppID, _HttpAddr, ServerKey1} = lists:keyfind(?PF_APP77, 1, PlatformLoginList),
%     ServerKey = list_to_binary(ServerKey1),
%     ServerTickStr = util:md5(<<ServerTickStr1/binary, ServerKey/binary>>),
% 	{_, ClientTickStr} = lists:keyfind(<<"Sign">>, 1, TickList),

% 	?DBG(background, "ServerTickStr1 = ~s", [binary_to_list(ServerTickStr1)]),

% 	?DBG(background, "ServerTickStr=~p, ClientTickStr=~p", [string:to_upper(ServerTickStr), string:to_upper(binary_to_list(ClientTickStr))]),
% 	string:to_upper(ServerTickStr) == string:to_upper(binary_to_list(ClientTickStr)).

% check_tick_4_xiaomi(TickList) ->
% 	F = fun({Key, Val}, BinStr) ->
% 		case Key of
% 			<<"signature">> ->
% 				BinStr;
% 			_ ->
% 				case BinStr of
% 					<<>> ->
% 						<<Key/binary, $=:8, Val/binary>>;
% 					_ ->
% 						<<BinStr/binary, $&:8, Key/binary, $=:8, Val/binary>>
% 				end
% 		end
% 	end,
% 	ServerTickStr1 = lists:foldl(F, <<>>, TickList),
% 	ServerTickStr2 = binary_to_list(ServerTickStr1),

% 	PlatformLoginList = util_oceanus:get_platform_login_list(),
%     {_, _, _AppID, _HttpAddr, ServerKey} = lists:keyfind(?PF_XIAOMI, 1, PlatformLoginList),
    
%     {ok, PHPExecPath} = application:get_env(oceanus, php_exec_path),

%     ?ERR(background, "TickList=~p", [TickList]),

%     PHPCmd = PHPExecPath ++ " php/check_key/hash_hmac_4_erlang.php '" ++ ServerTickStr2 ++ "' '" ++ ServerKey  ++ "'",
%     ?ERR(background, "PHPCmd = ~p", [PHPCmd]),

%     ServerTickStr = os:cmd(PHPCmd),

% 	{_, ClientTickStr} = lists:keyfind(<<"signature">>, 1, TickList),

% 	?DBG(background, "ServerTickStr=~p, ClientTickStr=~p", [string:to_upper(ServerTickStr), string:to_upper(binary_to_list(ClientTickStr))]),
% 	string:to_upper(ServerTickStr) == string:to_upper(binary_to_list(ClientTickStr)).

% check_tick_4_wdj(ContentStr, SignStr) ->
% 	{ok, PHPExecPath} = application:get_env(oceanus, php_exec_path),

% 	PHPCmd = PHPExecPath ++ " php/check_key/check_tick_4_wdj.php '" ++ binary_to_list(ContentStr) ++ "' '" ++ binary_to_list(SignStr) ++ "'",
% 	?ERR(background, "PHPCmd = ~s", [PHPCmd]),

% 	Reply = os:cmd(PHPCmd),

% 	case string:strip(Reply) of
% 		"SUCCESS" ->
% 			true;
% 		"FAILED" ->
% 			?ERR(background, "Other = FAILED"),
% 			false;
% 		Other ->
% 			?ERR(background, "Other = ~p", [Other]),
% 			false
% 	end.

% %% 多酷
% check_tick_4_duoku(Amount, CardType, OrderID, Result, Timestamp, Aid, Sign) ->
% 	PlatformLoginList = util_oceanus:get_platform_login_list(),
%     {_, _, _, _HttpAddr, ServerKey} = lists:keyfind(?PF_DUOKU, 1, PlatformLoginList),
		
% 	%% $client_secret=strtolower(md5($amount$cardtype$orderid$result$timetamp$AppSecret$aid)); 
% 	CalSign = string:to_lower(util:md5(Amount ++ CardType ++ OrderID ++ Result ++ Timestamp ++ ServerKey ++ Aid)),	
% 	CalSign == Sign.

% check_tick_4_new4399(TickList) ->
% 	F = fun({Key, Val1}, BinStr) ->
% 		case Key == <<"sign">> of
% 			true ->
% 				BinStr;
% 			false ->
% 				Val2 = binary_to_list(Val1),
% 				Val = list_to_binary(http_uri:decode(Val2)),
% 				<<BinStr/binary, Val/binary>>
% 		end
% 	end,
% 	ServerTickStr1 = lists:foldl(F, <<>>, TickList),

% 	PlatformLoginList = util_oceanus:get_platform_login_list(),
%     {_, _, _AppID, _HttpAddr, ServerKey1} = lists:keyfind(?PF_NEW_4399, 1, PlatformLoginList),
%     ServerKey = list_to_binary(ServerKey1),

%     ServerTickStr = util:md5(<<ServerTickStr1/binary, ServerKey/binary>>),
% 	{_, ClientTickStr} = lists:keyfind(<<"sign">>, 1, TickList),

% 	string:to_upper(ServerTickStr) == string:to_upper(binary_to_list(ClientTickStr)).

% %% @doc飞流校验florderId|orderid|productid|cardnO|amount|ret|cardstatus|merpriv  
% check_tick_4_feiliu(FlorderId,Orderid,Productid,Cardno,Amount,Ret,Cardstatus,Merpriv, VerifyString) ->
% 	try
% 		PubKey = get_public_key(?PF_FEILIU),
% 		Msg = public_key:decrypt_public(base64:decode(VerifyString), PubKey),
% 		[BflorderId,Borderid,Bproductid,Bcardno,Bamount,Bret,Bcardstatus,Bmerpriv] = re:split(Msg, "\\|"),
% 		binary_to_list(BflorderId) == FlorderId andalso
% 			binary_to_list(Borderid) == Orderid andalso
% 			binary_to_list(Bproductid) == Productid andalso
% 			binary_to_list(Bcardno) == Cardno andalso
% 			binary_to_list(Bamount) == Amount andalso
% 			binary_to_list(Bret) == Ret andalso
% 			binary_to_list(Bcardstatus) == Cardstatus andalso
% 			binary_to_list(Bmerpriv) == Merpriv
% 	catch ET:EM ->
% 		?ERR(background, "check_tick_4_feiliu exception ~p ~p", [ET, EM]),
% 		false
% 	end.

% %% @doc 超好玩
% check_tick_4_chaohaowan(UserCode,TradeNo,SignStr) ->
% 	PlatformLoginList = util_oceanus:get_platform_login_list(),
% 	{_, _, _, _, ServerKey} = lists:keyfind(?PF_CHAOHAOWAN, 1, PlatformLoginList),
% 	CalSign = util:md5(lists:append([UserCode, TradeNo, ServerKey])),
% 	string:to_lower(CalSign) == string:to_lower(SignStr).

% %% @doc 游戏多验证
% check_tick_4_youxi_duo(UserName, ChargeId, Money, SignStr) ->
% 	PlatformLoginList = util_oceanus:get_platform_login_list(),
% 	{_, _, _, _, ServerKey} = lists:keyfind(?PF_YOUXIDUO, 1, PlatformLoginList),
% 	CalSign = util:md5(lists:append([UserName,"|", ChargeId,"|", Money,"|", ServerKey])),
% 	string:to_lower(CalSign) == string:to_lower(SignStr).


% %% @doc 360签名验证
% check_tick_4_360(ContenList, SignStr) ->	
% 	FilterFun = fun({Key,Value}) -> %% sign sign_return 以及空值数据都不参与签名 
% 					case string:to_lower(binary_to_list(Key)) of
% 						"sign" ->
% 							false;
% 						"sign_return" ->
% 							false;
% 						_ ->
% 							case Value of
% 								<<"">> ->
% 									false;
% 								<<"0">> ->
% 									false;
% 								_ ->
% 									true
% 							end
% 					end
% 				end,
% 	List1 = lists:filter(FilterFun, ContenList),
% 	List2 = lists:keysort(1, List1),
    
% 	ValuesFun = fun({_Key, Value}, Acc) ->
% 						case Acc of
% 							"" ->
% 								binary_to_list(Value);
% 							_ ->
% 								Acc ++ "#" ++ binary_to_list(Value)
% 						end
% 			   end,
% 	ValuesStr1 = lists:foldl(ValuesFun, "", List2),
% 	PlatformList = util_oceanus:get_platform_login_list(),
% 	{_, _, _, _, AppSecret} = lists:keyfind(?PF_360, 1, PlatformList),
% 	ValuesStr = ValuesStr1 ++ "#" ++ AppSecret,
% 	CalSign = util:md5(ValuesStr),
% 	string:to_lower(CalSign) == string:to_lower(SignStr).

% check_tick_4_paojiao(ResDatStr, SignStr) ->
% 	Params = [{"v", "1.0"},
% 			  {"format", "xml"},
% 			  {"service", "do-pay"},
% 			  {"res_data", ResDatStr}],
% 	L = lists:keysort(1, Params),
% 	Fun = fun({Key, Value}, Acc) ->
% 				  case Acc of
% 					  "" ->
% 						  Key ++ "=" ++ Value;
% 					  _ ->
% 						  Acc ++ "&" ++ Key ++ "=" ++ Value
% 				  end
% 		  end,
% 	S = lists:foldl(Fun, "", L),
% 	PubKey = get_public_key(?PF_PAOJIAO),
% 	public_key:verify(list_to_binary(S),'md5',base64:decode(SignStr),PubKey).

% check_pay_id(PayID) ->
% 	case ets:insert_new(ets_order, {PayID}) of
% 		false ->
% 			processing;
% 		true ->
% 			cache:lookup(pay, PayID)
% 	end.

% %% @doc 木蚂蚁验证
% check_tick_4_mumayi(SignStr, OrderId) ->
% 	PlatformList = util_oceanus:get_platform_login_list(),
% 	{_, _, _, _, AppKey} = lists:keyfind(?PF_MUMAYI, 1, PlatformList),
	
% 	{ok, PHPExecPath} = application:get_env(oceanus, php_exec_path),

% 	PHPCmd = PHPExecPath ++ " php/check_key/check_tick_4_mumayi.php " ++ SignStr ++ " " ++ AppKey ++ " " ++ OrderId,
% 	?ERR(background, "PHPCmd = ~p", [PHPCmd]),

% 	case os:cmd(PHPCmd) of
% 		"success" ->
% 			true;
% 		"fail" ->
% 			?ERR(background, "Other = FAILED"),
% 			false;
% 		Other ->
% 			?ERR(background, "Other = ~p", [Other]),
% 			false
% 	end.

% %% @doc yy支付验证
% check_tick_4_yy(OrderIDStr, TransNum, UserName, AmountStr, PayStatusStr, SignStr) ->
% 	%% orderid.transnum.username.money.status.yayawan_payment_key 
% 	PlatformLoginList = util_oceanus:get_platform_login_list(),
% 	{_, PaymentKey, _, _, _} = lists:keyfind(?PF_YY, 1, PlatformLoginList),
% 	S = OrderIDStr ++ TransNum ++ UserName ++ AmountStr ++ PayStatusStr ++ PaymentKey,	
% 	CalSign = util:md5(S),
% 	string:to_lower(CalSign) == string:to_lower(SignStr).

% %% @doc 金立支付验证
% check_tick_4_jinli(ContentList, SignStr) ->
	
% 	MF = fun({Key,Value}, Acc) ->
% 				 case Key of
% 					 <<"sign">> -> %%忽略sign
% 						 Acc;
% 					 _ ->
% 						 case Acc of
% 							 "" ->
% 								 binary_to_list(Key) ++ "=" ++ binary_to_list(Value);
% 							 _ ->
% 								 Acc ++ "&" ++ binary_to_list(Key) ++ "=" ++ binary_to_list(Value)
% 						 end
% 				 end
% 		 end,
	
% 	S = lists:foldl(MF, "", lists:keysort(1, ContentList)),
	
% 	{ok, JAVAExecPath} = application:get_env(oceanus, java_exec_path),

% 	JAVACmd = JAVAExecPath ++ " -jar java/jinli.jar verify \"" ++ S ++ "\"  \"" ++ SignStr ++ "\"",
% 	?ERR(background, "jinli order JAVACmd ~p", [JAVACmd]),
% 	Ret  = os:cmd(JAVACmd),
% 	?ERR(background,"jinli order sig ret ~p",[Ret]),
% 	case Ret of
% 		"true" ->
% 			true;
% 		_ ->
% 			false
% 	end.

% %% @doc 云翎支付验证
% check_tick_4_yunling(AccountStr, AmountStr, OrderidStr, ResultStr, ChannelStr, MsgStr, ExtrainfoStr, SignStr) ->
% 	%% sign=MD5(account=77&amount=50&orderid=20130806123547852&result=0&channel=联通充值卡&msg=成功&extrainfo=25&appkey={appkey})
% 	{_, _, _, _, AppKey} = lists:keyfind(?PF_YUNLING, 1, util_oceanus:get_platform_login_list()),
% 	S = "account=" ++ AccountStr ++
% 			"&amount=" ++ AmountStr ++
% 			"&orderid=" ++ OrderidStr ++ 
% 			"&result=" ++ ResultStr ++ 
% 			"&channel=" ++ ChannelStr ++
% 			"&msg=" ++ MsgStr ++
% 			"&extrainfo=" ++ ExtrainfoStr ++
% 			"&appkey=" ++ AppKey,
% 	string:to_lower(util:md5(S)) == string:to_lower(SignStr).
  
% %% @doc 禅游支付验证
% check_tick_4_chanyou(OutorderidStr, GameIdStr, UserIdStr, AmountStr, GoodsIdStr, GoodsCountStr, SignStr) ->
% 	%% sign 签名 md5(orderId.GameId.UserId.Money.GoodsId.GoodsCount.key)
%  	{_, _, _, _, AppKey} = lists:keyfind(?PF_CHANYOU, 1, util_oceanus:get_platform_login_list()),
% 	S = OutorderidStr ++ GameIdStr ++ UserIdStr ++ AmountStr ++ GoodsIdStr ++ GoodsCountStr ++ AppKey,
% 	string:to_lower(util:md5(S)) == string:to_lower(SignStr).

% %% @doc华为支付验证
% check_tick_4_huawei(ContentList, SignStr) ->
% 	MF = fun({Key,Value}, Acc) ->
% 				 case Key of
% 					 <<"sign">> -> %%忽略sign
% 						 Acc;
% 					 _ ->
% 						 case Acc of
% 							 "" ->
% 								 binary_to_list(Key) ++ "=" ++ binary_to_list(Value);
% 							 _ ->
% 								 Acc ++ "&" ++ binary_to_list(Key) ++ "=" ++ binary_to_list(Value)
% 						 end
% 				 end
% 		 end,
	
% 	S = lists:foldl(MF, "", lists:keysort(1, ContentList)),
% 	PubKey = get_public_key(?PF_HUAWEI),
% 	public_key:verify(list_to_binary(S),'sha',base64:decode(SignStr),PubKey).

% %% @doc 冒泡支付验证
% check_tick_4_maopao(ContentList, SignStr) ->
% 	MF = fun({Key,Value}, Acc) ->
% 				 case Key of
% 					 <<"sign">> -> %%忽略sign
% 						 Acc;
% 					 _ ->
% 						 case Acc of
% 							 "" ->
% 								 binary_to_list(Key) ++ "=" ++ binary_to_list(Value);
% 							 _ ->
% 								 Acc ++ "&" ++ binary_to_list(Key) ++ "=" ++ binary_to_list(Value)
% 						 end
% 				 end
% 		 end,	
% 	S = lists:foldl(MF, "", lists:keysort(1, ContentList)),
% 	{_, _, _, _, AppKey} = lists:keyfind(?PF_MAOPAO, 1, util_oceanus:get_platform_login_list()),
% 	SS = S ++ "&sign=" ++ AppKey,
% 	string:to_lower(util:md5(SS)) == string:to_lower(SignStr).

% %% @doc 云游支付验证
% check_tick_4_yunyou(OutorderidStr, OrderIDStr, UnameStr, MoneyStr, AmountStr, AppIdStr, SidStr, TimeStr, SignStr) ->
% 	%%  Sign=md5(ordered+billno+uname+money+amount+appid+sid+t+KEY);
% 	{_, _, _, _, ServerKey} = lists:keyfind(?PF_YUNYOU, 1, util_oceanus:get_platform_login_list()),
% 	CalSign = util:md5(OutorderidStr ++ OrderIDStr ++ UnameStr ++ MoneyStr ++ AmountStr ++ AppIdStr ++ SidStr ++ TimeStr ++ ServerKey),
% 	string:to_lower(CalSign) == string:to_lower(SignStr).