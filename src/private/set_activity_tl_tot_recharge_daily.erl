-module(set_activity_tl_tot_recharge_daily).

-include("log.hrl").
-include("sys_macro.hrl").
-include("system.hrl").
-include("log_type.hrl").
-include("background.hrl").
-include("activity.hrl").

-export([handle/1]).

%% http://192.168.1.235:10010/background/set_activity_tl_tot_recharge_daily?stage=1&request_money=100&item_list=[{1,100}]&flag=
%% 关闭活动，由其他系统设定
handle(ArgList) ->
	Opraction = 
	case lists:keyfind(<<"operation">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma operation missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, Opraction0} ->
			util_background:bitstring_to_integer(Opraction0)
	end,

	% BeginTime = 
	% case lists:keyfind(<<"begin_time">>, 1, ArgList) of
	% 	false ->
	% 		?ERR(?MODULE, "parma begin_time missing"),
	% 		throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
	% 	{_, BeginTime0} ->
	% 		util_background:bitstring_to_integer(BeginTime0)
	% end,

	Stage = 
	case lists:keyfind(<<"stage">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma stage missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, Stage0} ->
			util_background:bitstring_to_integer(Stage0)
	end,

	RequestMoney = 
	case lists:keyfind(<<"request_money">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma request_money missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			99999999;
		{_, RequestMoney0} ->
			util_background:bitstring_to_integer(RequestMoney0)
	end,

	GiftID1 =
	case lists:keyfind(<<"gift_id">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma gift_id missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			0;
		{_, GiftID0} ->
			util_background:bitstring_to_integer(GiftID0)
	end,

	ItemList = 
	case lists:keyfind(<<"item_list">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma item_list missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, ItemList0} ->
			util_background:bitstring_to_term(ItemList0)
	end,

	case util_background:check_tick(ArgList) of
		false ->
			?ERR(?MODULE, "check flag error"),
			throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")}]}});
		true ->
			ok
	end,

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

	GiftID =
	case GiftID1 =< 0 of
		true ->
			#activity_tl_single_recharge_cfg{gift_id=GID} = data_activity_time_limit:get_single_recharge_cfg(Stage),
			GID;
		false ->
			GiftID1
	end,

	case cache:lookup(activity_tl_tot_recharge_daily_cfg, Stage) of
		[] ->
			case Opraction of
				2 ->
					ok;
				_ ->
					cache:insert(#activity_tl_tot_recharge_daily_cfg{ 
											stage = Stage,
											gift_id = GiftID,
											unlock_money = RequestMoney,
											item_list = ItemList
											})
				
			end;
		[TotRecharge] ->
			case Opraction of
				2 ->
					cache:delete(TotRecharge);
				_ ->
					cache:update(TotRecharge#activity_tl_tot_recharge_daily_cfg{
											stage = Stage,
											gift_id = GiftID,
											unlock_money = RequestMoney,
											item_list = ItemList
											})
			end
	end,

	{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")}]}.