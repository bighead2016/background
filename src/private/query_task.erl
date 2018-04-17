%% 任务查询

-module(query_task).

% -include("log.hrl").
% -include("account.hrl").

% -export([handle/1]).

% handle(ArgList) ->
% %% user_id		String	账号标识
% %% nick_name	String	角色名
% %% server_id	Int	服务器ID
% %% task_id		Int	任务类型
% %% timestamp	Int	时间戳
% %% sign	sign	校验码
% 	UserIdTuple = lists:keyfind(<<"user_id">>, 1, ArgList),
% 	NickNameTuple = lists:keyfind(<<"nick_name">>, 1, ArgList),
% 	ServerIdTuple = lists:keyfind(<<"server_id">>, 1, ArgList),
% 	TaskIdTuple = lists:keyfind(<<"task_id">>, 1, ArgList),
% 	TimestampTuple = lists:keyfind(<<"timestamp">>, 1, ArgList),
% 	SignTuple = lists:keyfind(<<"sign">>, 1, ArgList),
	
% 	case UserIdTuple == false orelse NickNameTuple == false orelse ServerIdTuple == false 
% 		orelse TaskIdTuple == false orelse SignTuple == false of
% 		true ->
% 			?ERR(background, "bgtask invalid parameters ~p",[ArgList]),
% 			<<"99">>;
% 		false ->
% 			{_, UserIdBin} = UserIdTuple,
% 			{_, NickNameBin} = NickNameTuple,
% 			{_, ServerIdBin} = ServerIdTuple,
% 			{_, TaskIdBin} = TaskIdTuple,
% 			{_, TimestampBin} = TimestampTuple,
% 			{_, SignBin} = SignTuple,
% 			UserIdStr = binary_to_list(UserIdBin),
% 			NickNameStr = binary_to_list(NickNameBin),
% 			ServerIdStr = binary_to_list(ServerIdBin),
% 			TaskIdStr = binary_to_list(TaskIdBin),
% 			TimestampStr = binary_to_list(TimestampBin),
% 			SignStr = binary_to_list(SignBin),
% 			case check_key(UserIdStr, NickNameStr, ServerIdStr, TaskIdStr, TimestampStr, SignStr) of
% 				false ->
% 					<<"1">>;
% 				true ->
% 					PlatformTuple = lists:keyfind(<<"platform">>, 1, ArgList),
% 					PlatformID = 
% 						case PlatformTuple of
% 							false ->
% 								get_platform_id(); %% 根据当前的帐号找一个 
% 							{_, <<"0">>} ->
% 								get_platform_id(); %% 根据当前的帐号找一个 
% 							{_, PlatformIDBin} ->
% 								binary_to_integer(PlatformIDBin)
% 						end,
% 					case mod_account:lookup_account(UserIdBin, list_to_integer(ServerIdStr), PlatformID) of
% 						{ok, AccRec} ->
% 							case mod_bg_task:check_task_finish(AccRec#account.id, list_to_integer(TaskIdStr)) of
% 								true ->
% 									<<"0">>;
% 								false ->
% 									<<"-1">>
% 							end;
% 						not_found ->
% 							<<"2">>
% 					end
% 			end
% 	end.

% get_platform_id() ->
% 	case ets:first(ets_account_id_map) of
% 		'$end_of_table' ->
% 			?PF_TW7725; %% 给个默认的 台湾安卓
% 		Key ->
% 			[Acc] = ets:lookup(ets_account_id_map, Key),
% 			{_, _, PlatformID} = Acc#account_id_map.account,
% 			PlatformID
% 	end.

% %% @doc sign = md5(user_id + nick_name + server_id + task_id + timestamp + key),
% check_key(UserIdStr,NickNameStr,ServerIdStr,TaskIdStr,TimestampStr, SignStr) ->
% 	KEY = "123456",
% 	Str = UserIdStr ++ NickNameStr ++ ServerIdStr ++ TaskIdStr ++ TimestampStr ++ KEY,
% 	string:to_lower(util:md5(Str)) == string:to_lower(SignStr).

