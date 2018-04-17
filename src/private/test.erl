-module(test).

-include("log.hrl").

-export([
		handle/1
		]).

handle(ArgList) ->
	User    = lists:keyfind("users", 1, ArgList),
	ID      = lists:keyfind("ids", 1, ArgList),
	PageArg = lists:keyfind("page", 1, ArgList),
	%RecNum = lists:keyfind("recnum", 1, ArgList),

	case User == false andalso ID == false of
		true ->
			"err param";
		false ->
			case User of
				false ->
					UserCond = "";
				{"users", ""} ->
					UserCond = "";
				{"users", UserStr} ->
					UserCond = " AND name IN (" ++ UserStr ++ ")"
			end,

			case ID of
				false ->
					IDCond = "";
				{"ids", ""} ->
					IDCond = "";
				{"ids", IDStr} ->
					IDCond = " AND ID IN (" ++ IDStr ++ ")"
			end,

			case PageArg of
				false ->
					Page = "1";
				{"page", ""} ->
					Page = "1";
				{"page", PageStr} ->
					Page = PageStr
			end,

			RecNum = 20,

			Sql = io_lib:format("SELECT ID, Name, Nick_Name FROM gd_Account WHERE 1=1~s~s",
				[IDCond, UserCond]),
			?INF(background, "Sql=~s", [Sql]),
			case sql_operate:do_execute(Sql) of
				{ok, Result} ->
					paseResult(Result);
				_ ->
					[{"error", "sql_execute_err"}]
			end
	end.

paseResult([[AccountID,Account,RoleName]|Rest]) ->
	%Account = erlang:binary_to_list(Account1),
	%RoleName = erlang:binary_to_list(RoleName1),
	%?INF(background, "AccountID=~p, Account=~p, RoleNmae=~p", [AccountID,Account,RoleName]),
	Result = {struct, [{id, AccountID},{account, Account},{rolename, RoleName}]},
	RestResult = paseResult(Rest),
	[Result|RestResult];
paseResult([]) ->
	[].