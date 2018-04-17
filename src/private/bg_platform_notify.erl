%% 通知成就变更
-module(bg_platform_notify).

-include("log.hrl").
-include("proto_const.hrl").

-export([handle/1]).

%% http://192.168.1.235:10010/background/ban_chat?user_names=2015032301&is_ban=1&ban_date=&flag=

handle(ArgList) ->
	AccountID =  
	case lists:keyfind(<<"account_id">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma account_id missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, AccountID0} ->
			util_background:bitstring_to_integer(AccountID0)
	end,

	Action = 
	case lists:keyfind(<<"action">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma action missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, Action0} ->
			util_background:bitstring_to_integer(Action0)
	end,

	% case util_background:check_tick(ArgList) of
	% 	false ->
	% 		?ERR(?MODULE, "check flag error"),
	% 		throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")}]}});
	% 	true ->
	% 		ok
	% end,
	case Action of
		3 ->
			catch mod_activity_daily:bg_platform_notify(AccountID, Action);
		_ ->
			catch mod_achieve:bg_platform_notify(AccountID, Action)
	end,

	{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")}]}.