-module(set_activity).

-include("log.hrl").
-include("sys_macro.hrl").
-include("system.hrl").
-include("log_type.hrl").
-include("background.hrl").
-include("activity.hrl").

-export([handle/1]).

%% http://192.168.1.235:10010/background/set_activity?activity_id=1&cycle_begin_time=&cycle_end_time=&prepare_time=10&duration=2&match_time_list=[]&match_week_list=[]&match_date_list=[]&flag=
%% 关闭活动，由其他系统设定
handle(ArgList) ->
	Action =
	case lists:keyfind(<<"action">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma action missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, Action0} ->
			util_background:bitstring_to_integer(Action0)
	end,

	ActivityID = 
	case lists:keyfind(<<"activity_id">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma activity_id missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, ActivityID0} ->
			util_background:bitstring_to_integer(ActivityID0)
	end,

	CycleBeginTime = 
	case lists:keyfind(<<"cycle_begin_time">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma cycle_begin_time missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			?ERR(?MODULE, "parma cycle_begin_time empty"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, CycleBeginTime0} ->
			{{Y,M,D},{_,_,_}} = util:unixtime_to_datetime(util_background:bitstring_to_integer(CycleBeginTime0)),
			{{Y,M,D},{0,0,0}}
	end,

	CycleEndTime = 
	case lists:keyfind(<<"cycle_end_time">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma cycle_end_time missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			?ERR(?MODULE, "parma cycle_end_time empty"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, CycleEndTime0} ->
			{{Y1,M1,D1},{_,_,_}} = util:unixtime_to_datetime(util_background:bitstring_to_integer(CycleEndTime0)),
			{{Y1,M1,D1},{0,0,0}}
	end,

	PrepareTime = 
	case lists:keyfind(<<"prepare_time">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma prepare_time missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, PrepareTime0} ->
			util_background:bitstring_to_integer(PrepareTime0)
	end,

	Duration = 
	case lists:keyfind(<<"duration">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma duration missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, Duration0} ->
			util_background:bitstring_to_integer(Duration0) * 3600
	end,

	MatchTimeList = 
	case lists:keyfind(<<"match_time_list">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma match_time_list missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, MatchTimeList0} ->
			util_background:bitstring_to_term(MatchTimeList0)
	end,

	MatchWeekList = 
	case lists:keyfind(<<"match_week_list">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma match_week_list missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, MatchWeekList0} ->
			util_background:bitstring_to_term(MatchWeekList0)
	end,

	MatchDateList = 
	case lists:keyfind(<<"match_date_list">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma match_date_list missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, MatchDateList0} ->
			util_background:bitstring_to_term(MatchDateList0)
	end,

	DataList =
	case lists:keyfind(<<"stageData">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma stageData missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, DataList0} ->
			mochijson2:decode(DataList0)
	end,

	Content1 =
	case lists:keyfind(<<"url">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma url missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, Content0} ->
			Content0
	end,

	% case util_background:check_tick(ArgList) of
	% 	false ->
	% 		?ERR(?MODULE, "check flag error"),
	% 		throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")}]}});
	% 	true ->
	% 		ok
	% end,

	try
		case is_list(MatchTimeList) andalso is_list(MatchWeekList) andalso is_list(MatchDateList) of
			true ->
				ok;
			false ->
				?ERR(?MODULE, "parma list fail, Info = ~p", [[MatchTimeList, MatchWeekList, MatchDateList]]),
				throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("参数中列表格式不对")}]}})
		end
	catch _:_ ->
		?ERR(?MODULE, "parma list fail, Info = ~p", [[MatchTimeList, MatchWeekList, MatchDateList]]),
		throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("参数中列表格式不对")}]}})
	end,

	#activity{ award_desc=AwardDesc,award_item_list=AwardItemList,activity_type=ActivityType,content=Content2 } = data_activity:get(ActivityID),

	[FirstBeginTime|_] = MatchTimeList,
	{CycleBeginDate, _} = CycleBeginTime,
	FirstEndTime = util:datetime_to_unixtime({CycleBeginDate, FirstBeginTime}) + Duration,
	Content = 
	case Content1 of
		<<>> ->
			Content2;
		_ ->
			Content1
	end,

	case Action of
		2 ->
			case cache:lookup(activity, ActivityID) of
				[] ->
					cache:insert(#activity{
											activity_id=ActivityID,
											activity_type=ActivityType,
											cycle_begin_time={{3014,1,1},{0,0,0}},
											cycle_end_time = {{1014,1,1},{0,0,0}},
											award_desc=AwardDesc,
											award_item_list=AwardItemList
											});
				[Activity] ->
					cache:update(Activity#activity{
											activity_id=ActivityID,
											activity_type=ActivityType,
											cycle_begin_time={{3014,1,1},{0,0,0}},
											cycle_end_time = {{1014,1,1},{0,0,0}},
											award_desc=AwardDesc,
											award_item_list=AwardItemList
											})
			end,
			g_activity:terminate_activity(ActivityID);
		_ ->
			RecName =
			case ActivityID of
				?ACTIVITY_TYPE_TL_TOT_RECHARGE ->
					activity_tl_tot_recharge_cfg;
				?ACTIVITY_TYPE_TL_TOT_CONSUME ->
					activity_tl_tot_consume_cfg;
				?ACTIVITY_TYPE_TL_TOT_RECHARGE_DAILY ->
					activity_tl_tot_recharge_daily_cfg;
				?ACTIVITY_TYPE_TL_TOT_CONSUME_DAILY ->
					activity_tl_tot_consume_daily_cfg;
				?ACTIVITY_TYPE_TL_TOT_RECHARGE_2 ->
					activity_tl_tot_recharge_2_cfg;
				?ACTIVITY_TYPE_TL_TOT_CONSUME_2 ->
					activity_tl_tot_consume_2_cfg;
				?ACTIVITY_TYPE_TL_TOT_RECHARGE_DAILY_2 ->
					activity_tl_tot_recharge_daily_2_cfg;
				?ACTIVITY_TYPE_TL_TOT_CONSUME_DAILY_2 ->
					activity_tl_tot_consume_daily_2_cfg;
				?ACTIVITY_TYPE_TL_SIGLE_RECHARGE ->
					activity_tl_single_recharge_cfg;
				?ACTIVITY_TYPE_TL_DIAMOND_CALL_ROLE ->
					activity_tl_diamond_call_role_cfg;
				?ACTIVITY_TYPE_TL_LOGIN_AWARD ->
					activity_tl_login_cfg;
				?ACTIVITY_TYPE_TL_CON_LOGIN_AWARD ->
					activity_tl_con_login_cfg;
				% ?ACTIVITY_TYPE_TL_RECHARGE_DIAMOND_RANK ->
				% 	activity_tl_recharge_diamond_rank_cfg;
				% ?ACTIVITY_TYPE_TL_CONSUME_DIAMOND_RANK ->
				% 	activity_tl_consume_diamond_rank_cfg;
				% ?ACTIVITY_TYPE_TL_CROSS_RECHARGE_DIAMOND_RANK ->
				% 	activity_tl_cross_recharge_diamond_rank_cfg;
				% ?ACTIVITY_TYPE_TL_CROSS_CONSUME_DIAMOND_RANK ->
				% 	activity_tl_cross_consume_diamond_rank_cfg;
				% ?ACTIVITY_TYPE_TL_CROSS_DAILY_RECHARGE_DIAMOND_RANK ->
				% 	activity_tl_cross_daily_recharge_diamond_rank_cfg;
				% ?ACTIVITY_TYPE_TL_CROSS_DAILY_CONSUME_DIAMOND_RANK ->
				% 	activity_tl_cross_daily_consume_diamond_rank_cfg;
				_ ->
					none
			end,

			case RecName == none of
				true ->
					ok;
				false ->
					cache:delete_all(RecName),
					Fun = fun({struct, L}) ->
						{_, Stage0} = lists:keyfind(<<"stage">>, 1, L),
						Stage = util_background:bitstring_to_integer(Stage0),

						{_, RequestMoney0} = lists:keyfind(<<"request_diamond">>, 1, L),
						RequestMoney = util_background:bitstring_to_integer(RequestMoney0),

						{_, GiftID0} = lists:keyfind(<<"gift_id">>, 1, L),
						GiftID1 = util_background:bitstring_to_integer(GiftID0),
						GiftID =
						case lists:member(GiftID1, [4003,4004,4005]) of
							true ->
								GiftID1;
							false ->
								4003
						end,
						
						{_, ItemList0} = lists:keyfind(<<"item_list">>, 1, L),
						ItemList = util_background:bitstring_to_term(ItemList0),

						try
							case is_list(ItemList) of
								true ->
									ok;
								false ->
									?ERR(?MODULE, "parma item_list fail, Info = ~p", [ItemList]),
									throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("参数中列表格式不对")}]}})
							end
						catch _:_ ->
							?ERR(?MODULE, "parma item_list fail, Info = ~p", [ItemList]),
							throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("参数中列表格式不对")}]}})
						end,

						Record = 
						case RecName of
							activity_tl_single_recharge_cfg ->
								#activity_tl_single_recharge_cfg{ min_money=MinMoney,max_money=MaxMoney} = data_activity_time_limit:get_single_recharge(Stage),
								#activity_tl_single_recharge_cfg{ stage=Stage,gift_id=GiftID,min_money=MinMoney,max_money=MaxMoney,item_list=ItemList };
							% activity_tl_recharge_diamond_rank_cfg ->
							% 	#activity_tl_recharge_diamond_rank_cfg{ min_rank=MinRank,max_rank=MaxRank} = data_activity_time_limit:get_single_recharge(Stage),
							% 	#activity_tl_recharge_diamond_rank_cfg{ stage=Stage,gift_id=GiftID,min_money=MinMoney,max_money=MaxMoney,item_list=ItemList };
							% activity_tl_consume_diamond_rank_cfg ->
							_ ->
								{RecName, Stage, GiftID, RequestMoney, ItemList}
						end,

						cache:insert(Record)

					end,
					lists:foreach(Fun, DataList)
			end,

			case cache:lookup(activity, ActivityID) of
				[] ->
					cache:insert(#activity{ 
											activity_id = ActivityID,
											activity_type=ActivityType,
											cycle_begin_time = CycleBeginTime,
											cycle_end_time = get_cycle_end_time(ActivityID, CycleEndTime, FirstEndTime),
											prepare_time = PrepareTime,
											duration = Duration,
											match_time_list = MatchTimeList,
											match_week_list = MatchWeekList,
											match_date_list = MatchDateList,
											award_desc=AwardDesc,
											award_item_list=AwardItemList,
											content = Content
											});
				[#activity{cycle_begin_time=OldCycleBeginTime,match_time_list=OldMatchTimeList,match_week_list=OldMatchWeekList,match_date_list=OldMatchDateList} = Activity] ->
					cache:update(Activity#activity{
											activity_id = ActivityID,
											activity_type=ActivityType,
											cycle_begin_time = CycleBeginTime,
											cycle_end_time = get_cycle_end_time(ActivityID, CycleEndTime, FirstEndTime),
											prepare_time = PrepareTime,
											duration = Duration,
											match_time_list = MatchTimeList,
											match_week_list = MatchWeekList,
											match_date_list = MatchDateList,
											award_desc=AwardDesc,
											award_item_list=AwardItemList,
											content = Content
											}),
					case CycleBeginTime == OldCycleBeginTime
					  andalso MatchTimeList == OldMatchTimeList
					  andalso MatchWeekList == OldMatchWeekList
					  andalso MatchDateList == OldMatchDateList of
						true ->
							g_activity:postpone_activity(ActivityID);
						false ->
							ok
					end
			end
	end,

	{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")}]}.


get_cycle_end_time(?ACTIVITY_TYPE_POWER_GET, EndTime, _) -> EndTime;
get_cycle_end_time(?ACTIVITY_TYPE_TL_WORLD_BOSS, EndTime, _) -> EndTime;
get_cycle_end_time(?ACTIVITY_TYPE_TL_PIG_DUN, EndTime, _) -> EndTime;
get_cycle_end_time(?ACTIVITY_TYPE_TL_TOT_RECHARGE_DAILY, EndTime, _) -> EndTime;
get_cycle_end_time(?ACTIVITY_TYPE_TL_TOT_CONSUME_DAILY, EndTime, _) -> EndTime;
get_cycle_end_time(?ACTIVITY_TYPE_TL_TOT_RECHARGE_DAILY_2, EndTime, _) -> EndTime;
get_cycle_end_time(?ACTIVITY_TYPE_TL_TOT_CONSUME_DAILY_2, EndTime, _) -> EndTime;
get_cycle_end_time(?ACTIVITY_TYPE_TL_PROTECT_GODNESS,EndTime,_) -> EndTime;

get_cycle_end_time(?ACTIVITY_TYPE_TL_TRIAL_TOWER_DOUBLE_SCORE,EndTime,_) -> EndTime;
get_cycle_end_time(?ACTIVITY_TYPE_TL_DUN_DOUBLE_AWARD,EndTime,_) -> EndTime;			%% 限时活动*副本双倍掉落

%% 除了上面的活动其他都默认为不循环活动
get_cycle_end_time(_, _, FirstEndTime) -> util:unixtime_to_datetime(FirstEndTime).