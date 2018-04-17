%% 禁言/解禁
-module(ban_chat).

-include("log.hrl").
-include("account.hrl").
-include("sys_macro.hrl").

-export([handle/1]).

%% http://192.168.1.235:10010/background/ban_chat?user_names=2015032301&is_ban=1&ban_date=&flag=

handle(ArgList) ->
	NameList =  
	case lists:keyfind(<<"user_names">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma user_names missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, NameList0} ->
			util_background:get_string_list(NameList0)
	end,

	IsBan = 
	case lists:keyfind(<<"is_ban">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma is_ban missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			1;
		{_, IsBan0} ->
			util_background:bitstring_to_integer(IsBan0)
	end,

	BanDate = 
	case lists:keyfind(<<"ban_date">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma ban_date missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			util:unixtime() + ?SECONDS_PER_YEAR;
		{_, BanDate0} ->
			util_background:bitstring_to_integer(BanDate0)
	end,

	case util_background:check_tick(ArgList) of
		false ->
			?ERR(?MODULE, "check flag error"),
			throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")}]}});
		true ->
			ok
	end,

	do_ban_chat(NameList, IsBan, BanDate),

	{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")}]}.

do_ban_chat([Name|Rest], IsBan, BanDate) ->
	case ets:lookup(ets_nickname_id_map, Name) of
		[] ->
			ok;
		[{Name, AccountID}] ->
			mod_account:forbid_chat(AccountID, IsBan, BanDate)
	end,
	do_ban_chat(Rest, IsBan, BanDate);
do_ban_chat([], _, _) ->
	ok.