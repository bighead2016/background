-module(forbid_login).

-include("log.hrl").
-include("account.hrl").
-include("sys_macro.hrl").

-export([handle/1]).

handle(ArgList) ->
	NameList = 
	case lists:keyfind(<<"user_names">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma user_names missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, NameList0} ->
			util_background:get_string_list(NameList0)
	end,

	IsForbid = 
	case lists:keyfind(<<"is_forbid">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma is_forbid missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			1;
		{_, IsForbid0} ->
			util_background:bitstring_to_integer(IsForbid0)
	end,

	ForbidTime = 
	case lists:keyfind(<<"forbid_time">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma forbid_time missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			util:unixtime() + ?SECONDS_PER_DAY;
		{_, ForbidTime0} ->
			util_background:bitstring_to_integer(ForbidTime0)
	end,

	case util_background:check_tick(ArgList) of
		false ->
			?ERR(?MODULE, "check flag error"),
			throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")}]}});
		true ->
			ok
	end,

	do_forbid_login(NameList, IsForbid, ForbidTime),
	{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")}]}.

do_forbid_login([Name|Rest], IsForbid, ForbidTime) ->
	case ets:lookup(ets_nickname_id_map, Name) of
		[] ->
			ok;
		[{_, AccountID}] ->
			mod_account:forbid_login(AccountID, IsForbid, ForbidTime)
	end,
	do_forbid_login(Rest, IsForbid, ForbidTime);
do_forbid_login([], _, _) ->
	ok.