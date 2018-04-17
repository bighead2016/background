%% 泛接口
-module(multifunction).

% -include("log.hrl").
% -include("account.hrl").
% -include("sys_macro.hrl").
% -include("login_bulletin.hrl").
% -include("activity.hrl").

% -export([handle/1]).

% handle(ArgList) ->
% 	ActionTuple = lists:keyfind(<<"action">>, 1, ArgList),

% 	case ActionTuple of
% 		{<<"action">>, ActionStr} when ActionStr /= <<>> ->
% 			case util_background:check_tick(ArgList) of
% 				false ->
% 					<<"flag_error">>;
% 				true ->
% 					case util_background:bitstring_to_integer(ActionStr) of
% 						1 ->
% 							set_server_upkeep(ArgList);
% 						2 ->
% 							deal_server(add, ArgList);
% 						3 ->
% 							deal_server(update, ArgList);
% 						4 ->
% 							add_login_bulletin(ArgList);
% 						5 ->
% 							delete_login_bulletin(ArgList);
% 						% 6 ->
% 						% 	get_back_rate_info(ArgList);
% 						6 ->
% 							add_activity(ArgList)
% 					end
% 			end;
% 		_ ->
% 			<<"param_error">>
% 	end.

% set_server_upkeep(ArgList) ->
% 	StatusTuple = lists:keyfind(<<"status">>, 1, ArgList),
% 	ServerIDTuple = lists:keyfind(<<"server_id">>, 1, ArgList),
% 	ContentTuple = lists:keyfind(<<"content">>, 1, ArgList),
% 	case StatusTuple == false orelse ServerIDTuple == false orelse ContentTuple == false of
% 		true ->
% 			<<"flag_error">>;
% 		false ->
% 			{<<"status">>, StatusStr} = StatusTuple,
% 			{<<"server_id">>, ServerIDStr} = ServerIDTuple,
% 			{<<"content">>, ContentStr} = ContentTuple,
% 			ServerID = util_background:bitstring_to_integer(ServerIDStr),
% 			Status = util_background:bitstring_to_integer(StatusStr),
% 			case ServerID > 0 andalso Status > 0 of
% 				false ->
% 					<<"flag_error">>;
% 				true ->
% 					{ok, OceanusStatusNode} = application:get_env(background, oceanus_state_node),
% 					?DBG(background, "OceanusStatusNode = ~p", [OceanusStatusNode]),
% 					?DBG(background, "[ServerID, Status, ContentStr] = ~p", [[ServerID, Status, ContentStr]]),
% 					case Status of
% 						1 ->
% 							%关服维护
% 							rpc:cast(OceanusStatusNode, servers_handler, server_maintenance, [ServerID, ContentStr]);
% 						_ ->
% 							rpc:cast(OceanusStatusNode, servers_handler, server_up, [ServerID])
% 					end,
% 					<<"success">>
% 			end
% 	end.

% deal_server(Action, ArgList) ->
% 	ServerIDTuple = lists:keyfind(<<"server_id">>, 1, ArgList),
% 	ServerNameTuple = lists:keyfind(<<"server_name">>, 1, ArgList),
% 	ServerIPTuple = lists:keyfind(<<"server_ip">>, 1, ArgList),
% 	ServerPortTuple = lists:keyfind(<<"server_port">>, 1, ArgList),
% 	OpenTimeTuple = lists:keyfind(<<"open_time">>, 1, ArgList),
% 	ContentTuple = lists:keyfind(<<"content">>, 1, ArgList),
% 	BGPortTuple = lists:keyfind(<<"bg_port">>, 1, ArgList),
% 	case ServerIDTuple == false orelse ServerNameTuple == false orelse ServerIPTuple == false
% 	  orelse ServerPortTuple == false orelse OpenTimeTuple == false orelse ContentTuple == false of
% 		true ->
% 			<<"flag_error">>;
% 		false ->
% 			{<<"server_id">>, ServerIDStr} = ServerIDTuple,
% 			{<<"server_name">>, ServerName} = ServerNameTuple,
% 			{<<"server_ip">>, ServerIP} = ServerIPTuple,
% 			{<<"server_port">>, ServerPortStr} = ServerPortTuple,
% 			{<<"open_time">>, OpenTimeStr} = OpenTimeTuple,
% 			{<<"content">>, ContentStr} = ContentTuple,
% 			{<<"bg_port">>, BGPortStr} = BGPortTuple,
% 			ServerID = util_background:bitstring_to_integer(ServerIDStr),
% 			ServerPort = util_background:bitstring_to_integer(ServerPortStr),
% 			OpenTime = util_background:bitstring_to_integer(OpenTimeStr),
% 			BGPort = util_background:bitstring_to_integer(BGPortStr),
% 			case ServerID > 0 andalso ServerPort > 0 andalso OpenTime > 0 of
% 				false ->
% 					<<"flag_error">>;
% 				true ->
% 					{ok, OceanusStatusNode} = application:get_env(background, oceanus_state_node),
% 					?DBG(background, "OceanusStatusNode = ~p", [OceanusStatusNode]),
% 					?DBG(background, "[ServerID, ServerName, ServerIP, ServerPort, BGPort, ServerID, OpenTime, ContentStr] = ~p", [[ServerID, ServerName, ServerIP, ServerPort, BGPort, ServerID, OpenTime, ContentStr]]),
% 					case Action of
% 						add ->
% 							rpc:cast(OceanusStatusNode, servers_handler, new_server, [ServerID, ServerName, ServerIP, ServerPort, BGPort, ServerID, OpenTime, ContentStr]);
% 						update ->
% 							rpc:cast(OceanusStatusNode, servers_handler, update_server, [ServerID, ServerName, ServerIP, ServerPort, BGPort, ServerID, OpenTime, ContentStr])
% 					end,
% 					<<"success">>
% 			end
% 	end.

% get_back_rate(ArgList) ->
% 	case lists:keyfind(<<"begindate">>, 1, ArgList) of
% 		{<<"begindate">>, BeginDateStr} when BeginDateStr /= <<>> ->
% 			case lists:keyfind(<<"enddate">>, 1, ArgList) of
% 				{<<"enddate">>, EndDateStr} when EndDateStr /= <<>> ->
% 					FromRecNum = BeginDateStr,
% 					ToRecNum = EndDateStr,
% 					WhereCond = "WHERE stat_date BETWEEN ? AND ?",
% 					LimitCond = "";
% 				_ ->
% 					FromRecNum = 0,
% 		            ToRecNum = 30,
% 		            WhereCond = "",
% 		            LimitCond = "LIMIT ?,?"
% 		    end;
% 		_ ->
% 			FromRecNum = 0,
%             ToRecNum = 30,
%             WhereCond = "",
%             LimitCond = " LIMIT ?,?"
% 	end,

% 	Desc1 = {struct, [
% 					 {date, <<"日期">>},
% 					 {ip_tot_num, <<"首日IP总数">>},
% 					 {ip_back_num, <<"当日IP回访数">>},
% 					 {ip_back_rate, <<"IP回访率">>},
% 					 {acc_tot_num, <<"首日账号总数">>},
% 					 {acc_back_num, <<"当日账号回访数">>},
% 					 {acc_back_rate, <<"账号回访率">>}
% 					]},
% 	Desc = {desc, Desc1},

% 	Sql = io_lib:format("SELECT stat_date,stat_IPTotNum,stat_IPBackNum,stat_IPBackRate,stat_AccountTotNum,stat_AccountBackNum,stat_AccountBackRate FROM zs_stat.stat_backrate ~s ORDER BY stat_date DESC ~s",
% 						[WhereCond,LimitCond]),
% 	?DBG(background, "Sql = ~s", [Sql]),
% 	case emysql:execute(oceanus_log_pool, Sql, [FromRecNum, ToRecNum]) of
% 		{result_packet,_,_,Result,_} ->
% 			Status = {state, <<"success">>},
% 			Data1 = paseResult(Result),
% 			Data = {data, Data1};
% 		_ ->
% 			Status = {state, <<"failed">>},
% 			Data = {data, <<>>}
% 	end,
% 	{struct, [Status, Desc, Data]}.

% paseResult([[{date, {Y,M,D}},IPTotNum,IPBackNum,IPBackRate,AccountTotNum,AccountBackNum, AccountBackRate]|RestList]) -> 
% 	DateStr = list_to_binary(integer_to_list(Y) ++ integer_to_list(M) ++ integer_to_list(D)),
% 	Result = {struct, [
% 						{date, DateStr},{ip_tot_num, IPTotNum},{ip_back_num, IPBackNum},{ip_back_rate, IPBackRate},
% 						{acc_tot_num, AccountTotNum}, {acc_back_num, AccountBackNum},{acc_back_rate, AccountBackRate}
% 					]},
% 	RestResult = paseResult(RestList),
% 	[Result|RestResult];
% paseResult([]) ->
% 	[].

% add_login_bulletin(ArgList) -> 
% 	BulletinIDTuple = lists:keyfind(<<"Bulletin_id">>, 1, ArgList),
% 	StartTimeTuple = lists:keyfind(<<"start_time">>, 1, ArgList),
% 	EndTimeTuple = lists:keyfind(<<"end_time">>, 1, ArgList),
% 	TopShowTuple = lists:keyfind(<<"top_show">>, 1, ArgList),
% 	TitleTuple = lists:keyfind(<<"title">>, 1, ArgList),
% 	ContentTuple = lists:keyfind(<<"content">>, 1, ArgList),
% 	LinkTuple = lists:keyfind(<<"link">>, 1, ArgList),

% 	case StartTimeTuple == false orelse EndTimeTuple == false orelse TitleTuple == false
% 	  orelse ContentTuple == false orelse LinkTuple == false orelse BulletinIDTuple == false of
% 		true ->
% 			<<"flag_error">>;
% 		false ->
% 			case BulletinIDTuple of
% 				{_, <<>>} ->
% 					<<"flag_error">>;
% 				{_, BulletinIDStr} ->
% 					BulletinID = util_background:bitstring_to_integer(BulletinIDStr),
% 					StartTime = 
% 					case StartTimeTuple of
% 						{_, <<>>} ->
% 							util:unixtime();
% 						{_, StartTimeStr} ->
% 							util_background:bitstring_to_integer(StartTimeStr)
% 					end,
% 					EndTime = 
% 					case EndTimeTuple of
% 						{_, <<>>} ->
% 							StartTime + ?SECONDS_PER_DAY*30;
% 						{_, EndTimeStr} ->
% 							case util_background:bitstring_to_integer(EndTimeStr) of
% 								ET when ET < StartTime ->
% 									StartTime + ?SECONDS_PER_DAY*30;
% 								ET ->
% 									ET
% 							end
% 					end,

% 					TopShow =
% 					case TopShowTuple of
% 						{_, <<>>} ->
% 							0;
% 						{_, TopShowStr} ->
% 							util_background:bitstring_to_integer(TopShowStr)
% 					end,

% 					{_, Title} = TitleTuple,
% 					{_, Content} = ContentTuple,
% 					{_, Link1} = LinkTuple,

% 					Link = binary:replace(Link1, <<"//127.0.0.1">>, <<"//www.facebook.com">>),

% 					LoginBulletin = #login_bulletin{
% 							bulletin_id = BulletinID,
% 							start_time = StartTime,
% 							end_time = EndTime,
% 							top_show = TopShow,
% 							title = Title,
% 							content = Content,
% 							link = Link
% 					},
% 					catch cache:insert(LoginBulletin),
% 					<<"success">>
% 			end
% 	end.

% delete_login_bulletin(ArgList) -> 
% 	case lists:keyfind(<<"Bulletin_id">>, 1, ArgList) of
% 		{_, BulletinIDStr} when BulletinIDStr /= <<>> ->
% 			BulletinID = util_background:bitstring_to_integer(BulletinIDStr),
% 			case cache:lookup(login_bulletin, BulletinID) of
% 				[] ->
% 					skip;
% 				[LoginBulletin] ->
% 					cache:delete(LoginBulletin)
% 			end,
% 			<<"success">>;
% 		_ ->
% 			<<"flag_error">>
% 	end.

% get_back_rate_info(ArgList) ->
	  
% 	Desc1 = {struct, [
% 					 {date, <<"日期">>},
% 					 {reg_num, <<"注册人数">>},
% 					 {activity_num, <<"活跃人数">>},
% 					 {avg_online_time, <<"平均在线时长(分钟)">>},
% 					 {avg_online_num, <<"平均在线人数">>},
% 					 {pay_num, <<"付费人数">>},
% 					 {new_pay_num, <<"新付费人数">>},
% 					 {pay_sum, <<"充值金额">>},
% 					 {max_online_num, <<"最高在线">>},
% 					 {back1, <<"次日留存率%">>},
% 					 {back2, <<"2日留存率%">>},
% 					 {back3, <<"3日留存率%">>},
% 					 {back4, <<"4日留存率%">>},
% 					 {back5, <<"5日留存率%">>},
% 					 {back6, <<"6日留存率%">>},
% 					 {back7, <<"7日留存率%">>},
% 					 {back15, <<"15日留存率%">>},
% 					 {back30, <<"30日留存率%">>}
% 					]},
% 	Desc = {desc, Desc1},

% 	case lists:keyfind(<<"start_time">>, 1, ArgList) of
% 		false ->
% 			Cond = "ORDER BY stat_Date Desc Limit 30 ",
% 			BeginDate = [],
% 			EndDate = [];
% 		{_, BeginDateStr} ->
% 			case lists:keyfind(<<"end_time">>, 1, ArgList) of
% 				false ->
% 					Cond = "WHERE stat_Date >= '?' ORDER BY stat_Date Limit 30",
% 					BeginDate = binary_to_list(BeginDateStr),
% 					EndDate = [];
% 				{_, EndDateStr} ->
% 					BeginDate = binary_to_list(BeginDateStr),
% 					EndDate = binary_to_list(EndDateStr),
% 					Cond = "WHERE stat_Date >= '?' AND stat_date <= '?' ORDER BY stat_Date"
% 			end
% 	end,

% 	{ok, StatTabName} = application:get_env(background, db_stat_name),

% 	Sql = "SELECT CAST(stat_date AS CHAR), stat_RegNum, stat_ActiveNum, stat_AvgOnlineTime, stat_AvgOnlineNum, stat_PayNum, stat_NewPayNum, stat_PaySum, stat_MaxOnlineNum, 
% 	(stat_AccountBackRate1)*100, (stat_AccountBackRate2)*100, (stat_AccountBackRate3)*100, (stat_AccountBackRate4)*100, (stat_AccountBackRate5)*100, 
% 	(stat_AccountBackRate6)*100, (stat_AccountBackRate7)*100, (stat_AccountBackRate15)*100, (stat_AccountBackRate30)*100 FROM " ++ StatTabName ++ ".stat_backrate " ++ Cond,

% 	?ERR(background, "Sql = ~s", [Sql]),

% 	case emysql:execute(oceanus_pool, Sql, lists:flatten([BeginDate, EndDate])) of
% 		{result_packet,_,_,Result,_} ->
			
% 			State = {state, <<"success">>},
% 			Data1 = paseResult6(Result),
% 			?ERR(background, "Data1 = ~p", [Data1]),
% 			Count = length(Data1),
% 			TotNum = {total_number, Count},
% 			Data = {data, Data1};
% 		_ ->
% 			?DBG(background, "Sql=~s", [Sql]),
% 			TotNum = {total_number, 0},
% 			State = {state, <<"failed">>},
% 			Data = {data, <<>>}
% 	end,



% 	{struct, [TotNum, State, Desc, Data]}.

% paseResult6([[Date,RegNum,ActivityNum,AvgOnlineTime,AvgOnlineNum,PayNum,NewPayNum,PaySum,MaxOnlineNum,Back1,Back2,Back3,Back4,Back5,Back6,Back7,Back15,Back30]|Rest]) ->
% 	Result = {struct, [
% 					   {date, Date},{reg_num, RegNum},{activity_num, ActivityNum},{avg_online_time, AvgOnlineTime},{avg_online_num, AvgOnlineNum},{pay_num, PayNum},{new_pay_num,NewPayNum},{pay_sum,PaySum},{max_online_num,MaxOnlineNum},
% 					   {back1, Back1},{back2, Back2},{back3, Back3},{back4, Back4},{back5, Back5},{back6, Back6},{back7, Back7},{back15, Back15},{back30, Back30}
% 					  ]},
% 	RestResult = paseResult6(Rest),
% 	[Result|RestResult];
% paseResult6([]) ->
% 	[].

% add_activity(ArgList) ->
% 	ActivityIDTuple = lists:keyfind(<<"activity_id">>, 1, ArgList),
% 	StartTimeTuple = lists:keyfind(<<"start_time">>, 1, ArgList),
% 	IsOpenBeginTuple = lists:keyfind(<<"is_open_begin">>, 1, ArgList),
% 	OpenBeginTimeTuple = lists:keyfind(<<"open_begin_time">>, 1, ArgList),
% 	DurationTuple = lists:keyfind(<<"duration">>, 1, ArgList),
% 	InterTimeTuple = lists:keyfind(<<"inter_time">>, 1, ArgList),
% 	IsTipsTuple = lists:keyfind(<<"is_tips">>, 1, ArgList),
% 	TipsTimeTuple = lists:keyfind(<<"tips_time">>, 1, ArgList),

% 	case StartTimeTuple == false orelse StartTimeTuple == false orelse IsOpenBeginTuple == false
% 	  orelse OpenBeginTimeTuple == false orelse DurationTuple == false orelse InterTimeTuple == false 
% 	  orelse IsTipsTuple == false orelse TipsTimeTuple == false of
% 		true ->
% 			<<"flag_error">>;
% 		false ->
% 			case ActivityIDTuple of
% 				{_, <<>>} ->
% 					<<"flag_error">>;
% 				{_, ActivityIDStr} ->
% 					ActivityID = util_background:bitstring_to_integer(ActivityIDStr),

% 					StartUnixTime = 
% 					case StartTimeTuple of
% 						{_, <<>>} ->
% 							util:unixtime() + ?SECONDS_PER_DAY * 3650;
% 						{_, StartTimeStr} ->
% 							util_background:bitstring_to_integer(StartTimeStr)
% 					end,

% 					{IsOpenBegin, OpenBeginTime, StartTime} = 
% 					case IsOpenBeginTuple of
% 						{_, <<"1">>} ->
% 							case OpenBeginTimeTuple of
% 								{_, <<>>} ->
% 									{ 1, {0, {0,0,0}}, {{0,0,0},{0,0,0}} };
% 								{_, OpenBeginTimeStr} ->
% 									OpenBeginUnxiTime = util_background:bitstring_to_integer(OpenBeginTimeStr),
% 									{ 1, calendar:seconds_to_daystime(OpenBeginUnxiTime), {{0,0,0},{0,0,0}} }
% 							end;
% 						_ ->
% 							{ 0, {0, {0,0,0}}, util:unixtime_to_datetime(StartUnixTime) }
% 					end,

% 					Duration =
% 					case DurationTuple of
% 						{_, <<>>} ->
% 							0;
% 						{_, DurationStr} ->
% 							util_background:bitstring_to_integer(DurationStr)
% 					end,

% 					InterTime =
% 					case InterTimeTuple of
% 						{_, <<>>} ->
% 							0;
% 						{_, InterTimeStr} ->
% 							util_background:bitstring_to_integer(InterTimeStr)
% 					end,

% 					IsTips =
% 					case IsTipsTuple of
% 						{_, <<>>} ->
% 							0;
% 						{_, IsTipsStr} ->
% 							util_background:bitstring_to_integer(IsTipsStr)
% 					end,

% 					TipsTime =
% 					case TipsTimeTuple of
% 						{_, <<>>} ->
% 							0;
% 						{_, TipsTimeStr} ->
% 							util_background:bitstring_to_integer(TipsTimeStr)
% 					end,

% 					{Duration0, InterTime0} =
% 					case util:unixtime_to_datetime(StartUnixTime) of
% 						{{Y, _, _}, _} when Y < 2014 ->
% 							RegName = list_to_atom("g_activity" ++ integer_to_list(ActivityID)),
% 							RegName ! {end_activity, true},
% 							{?SECONDS_PER_DAY, 0};
% 						_ ->
% 							{Duration, InterTime}
% 					end,

% 					case cache:lookup(cfg_activity, ActivityID) of
% 						[] ->
% 							CfgActivity = #cfg_activity{ cfg_ActivityID    = ActivityID,
% 														 cfg_BeginTime     = StartTime,
% 														 cfg_IsOpenBegin   = IsOpenBegin,
% 														 cfg_OpenBeginTime = OpenBeginTime,
% 														 cfg_Duration      = Duration0,
% 														 cfg_InterTime     = InterTime0,
% 														 cfg_IsTips        = IsTips,
% 														 cfg_TipsTime      = TipsTime
% 														 },
% 							cache:insert(CfgActivity);
% 						[CfgActivity] ->
% 							NewCfgActivity = CfgActivity#cfg_activity{ cfg_BeginTime     = StartTime,
% 																	   cfg_IsOpenBegin   = IsOpenBegin,
% 																	   cfg_OpenBeginTime = OpenBeginTime,
% 																	   cfg_Duration      = Duration0,
% 																	   cfg_InterTime     = InterTime0,
% 																	   cfg_IsTips        = IsTips,
% 																	   cfg_TipsTime      = TipsTime
% 																	   },
% 							cache:update(NewCfgActivity)
% 					end,

					

% 					<<"success">>
% 			end
% 	end.