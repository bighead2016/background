%% 踢玩家下线（不支持T所有玩家下线）
-module(kick_user).

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

	case util_background:check_tick(ArgList) of
		false ->
			?ERR(?MODULE, "check flag error"),
			throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")}]}});
		true ->
			ok
	end,

	NameIDList = lists:flatten([ets:lookup(ets_nickname_id_map, Name)|| Name <- NameList]),
	do_kick_user(NameIDList),
	{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")}]}.

do_kick_user([{_, AccountID}|Rest]) ->
	?DBG(background, "kick user ~p", [AccountID]),
	case ets:lookup(ets_online, AccountID) of
		[] ->
			skip;
		[{_, Pid}] ->
			gen_server:cast(Pid, {kickout, kick_user})
	end,
	do_kick_user(Rest);
do_kick_user([]) ->
	ok.