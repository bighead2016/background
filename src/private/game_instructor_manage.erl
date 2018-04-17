-module(game_instructor_manage).

-include("log.hrl").
-include("account.hrl").
-include("sys_macro.hrl").
-include("mail.hrl").

-export([handle/1]).

handle(ArgList) ->
	NameStr = 
	case lists:keyfind(<<"user_name">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma user_name missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, Name0} ->
			Name0
	end,

	TypeStr = 
	case lists:keyfind(<<"type">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma type missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, Type0} ->
			Type0
	end,

	AccountType =  
	case lists:keyfind(<<"instructor_type">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma instructor_type missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, InsType0} when TypeStr == <<"1">> ->
			max(0, util_background:bitstring_to_integer(InsType0));
		{_, _InsType0} ->
			0
	end,

	EndTime = 
	case lists:keyfind(<<"end_time">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma end_time missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, EndTime0} ->
			util_background:bitstring_to_integer(EndTime0)
	end,

	case util_background:check_tick(ArgList) of
		false ->
			?ERR(?MODULE, "check flag error"),
			throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")}]}});
		true ->
			ok
	end,

	case ets:lookup(ets_nickname_id_map, NameStr) of
		[] ->
			skip;
		[{_, AccountID}] ->
			catch mod_account:set_account_type(AccountID, AccountType)
	end,
	{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")}]}.