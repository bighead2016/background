%% 封禁/解封IP
-module(ip_ban).

% -include("log.hrl").
% -include("account.hrl").
% -include("sys_macro.hrl").
% -include("cache.hrl").

% -export([handle/1]).

% handle(ArgList) ->
% 	IPList = 
% 	case lists:keyfind(<<"ip">>, 1, ArgList) of
% 		false ->
% 			?ERR(?MODULE, "parma ip missing"),
% 			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
% 		{_, <<>>} ->
% 			throw({struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")}]}).
% 		{_, IPList0} ->
% 			util_background:get_string_list(IPList0)
% 	end,

% 	IsForbid = 
% 	case lists:keyfind(<<"is_forbid">>, 1, ArgList) of
% 		false ->
% 			?ERR(?MODULE, "parma is_forbid missing"),
% 			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
% 		{_, <<>>} ->
% 			1;
% 		{_, IsForbid0} ->
% 			util_background:bitstring_to_integer(IsForbid0)
% 	end,

% 	ForbidTimeTuple = 
% 	case lists:keyfind(<<"forbid_time">>, 1, ArgList) of
% 		false ->
% 			?ERR(?MODULE, "parma forbid_time missing"),
% 			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
% 		{_, <<>>} ->
% 			util:unixtime() + ?SECONDS_PER_DAY;
% 		{_, ForbidTime0} ->
% 			util_background:bitstring_to_integer(ForbidTime0)
% 	end,

% 	case util_background:check_tick(ArgList) of
% 		false ->
% 			?ERR(?MODULE, "check flag error"),
% 			throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")},{data, <<>>},{desc, Desc}]}});
% 		true ->
% 			ok
% 	end,

% 	case IsForbid of
% 		1 ->
% 			AccountList1 = ets:tab2list(ets_online),
% 			AccountList = [{mod_account:lookup_account(ID), Pid} || {ID, Pid} <- AccountList1],
% 			do_ip_ban(IPList,ForbidTime,AccountList);
% 		_ ->
% 			do_ip_ban(IPList)
% 	end,

% 	{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")}]}.

% do_ip_ban([IP|Rest]) ->
% 	ForbidIPList = cache:tab2list(forbid_ip),
% 	?DBG(background, "forbid_ip=~p, List=~p", [IP, ForbidIPList]),
% 	case lists:keyfind(IP, #forbid_ip.ip, ForbidIPList) of
% 		false ->
% 			skip;
% 		IPBan ->
% 			cache:delete(IPBan)
% 	end,
% 	do_ip_ban(Rest);
% do_ip_ban([]) ->
% 	ok.

% do_ip_ban([IP|Rest], ForbidTime, AccountList) ->
% 	ForbidIPList = cache:tab2list(forbid_ip),
% 	?DBG(background, "forbid_ip=~p, List=~p", [IP, ForbidIPList]),
% 	case lists:keyfind(IP, #forbid_ip.ip, ForbidIPList) of
% 		false ->
% 			KeyID = get_max_key_id() + 1,
% 			IPBan = #forbid_ip{ key_id=KeyID, ip=IP,forbid_limit_time=ForbidTime },
% 			?DBG(background, "KeyID=~p, IPBan=~p", [KeyID, IPBan]),
% 			cache:insert(IPBan),
% 			F = fun({AccRec, Pid}) ->
% 				case AccRec#account.ip == IP of
% 					true ->
% 						Pid ! logout;
% 					false ->
% 						skip
% 				end
% 			end,
% 			lists:map(F, AccountList);
% 		[IPBan] when ForbidTime > IPBan#forbid_ip.forbid_limit_time ->
% 			cache:update(IPBan#forbid_ip{ forbid_limit_time=ForbidTime });
% 		_ ->
% 			skip
% 	end,
% 	do_ip_ban(Rest, ForbidTime, AccountList);
% do_ip_ban(_, _, _) ->
% 	ok.

% get_max_key_id() ->
%     ForbidIPMap = map_data:map(forbid_ip),
%     [ForbidIPKeyFieldName] = ForbidIPMap#map.key_fields,
%     SQL = io_lib:format(<<"SELECT IFNULL(MAX(~s), 0) FROM ~s;">>,
%                         [ForbidIPKeyFieldName, sql_operate:make_sql_tab(forbid_ip)]),
%     {ok, [[MaxID]]} = sql_operate:do_execute(SQL),
%     ?DBG(forbid_ip, "MaxID = ~p", [MaxID]),
%     MaxID.