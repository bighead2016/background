-module(recharge_notify_4_anysdk).

-include("recharge.hrl").
-include("account.hrl").
-include("log.hrl").

-compile(export_all).
%% "http://192.168.1.3:9999/recharge_notify_4_twand_7725?amount=30&game=1&server=1&gold=320&info=150422000010000001&item=&orderid=1&paytype=&pvc=1&roleid=812&rolename=9100&timestamp=1469280000&userid=f9978ce98e4e40b93e3ceb61a08121ee&sign=758fdd12f141bdd8336df55a41bd7565"
%% SELECT MD5("amount=30game=1server=1gold=320info=150422000010000001item=orderid=1paytype=pvc=1roleid=812rolename=9100timestamp=1469280000userid=f9978ce98e4e40b93e3ceb61a08121eeyudaogserverkeyd2d7a18dfdda829a2f36")

handle(ContentList, Req) ->
	OrderID =
	case lists:keyfind(<<"order_id">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma order_id missing"),
			throw({error, "parma order_id missing"});
		{_, OrderID0} ->
			OrderID0
	end,

	ProductCount =
	case lists:keyfind(<<"product_count">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma product_count missing"),
			throw({error, "parma product_count missing"});
		{_, ProductCount0} ->
			util_background:bitstring_to_integer(ProductCount0)
	end,

	Amount =
	case lists:keyfind(<<"amount">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma amount missing"),
			throw({error, "parma amount missing"});
		{_, Amount0} ->
			Amount0
	end,

	PayStatus =
	case lists:keyfind(<<"pay_status">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma pay_status missing"),
			throw({error, "parma pay_status missing"});
		{_, PayStatus0} ->
			util_background:bitstring_to_integer(PayStatus0)
	end,

	PayTime =
	case lists:keyfind(<<"pay_time">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma pay_time missing"),
			throw({error, "parma pay_time missing"});
		{_, PayTime0} ->
			util:timestamp_to_unixtime(PayTime0)
	end,

	UserID =
	case lists:keyfind(<<"user_id">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma user_id missing"),
			throw({error, "parma user_id missing"});
		{_, UserID0} ->
			UserID0
	end,


	OrderType =
	case lists:keyfind(<<"order_type">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma order_type missing"),
			throw({error, "parma order_type missing"});
		{_, OrderType0} ->
			OrderType0
	end,
	
	GameUserID =
	case lists:keyfind(<<"game_user_id">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma game_user_id missing"),
			throw({error, "parma game_user_id missing"});
		{_, GameUserID0} ->
			util_background:bitstring_to_integer(GameUserID0)
	end,

	ServerID =
	case lists:keyfind(<<"server_id">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma server_id missing"),
			throw({error, "parma server_id missing"});
		{_, ServerID0} ->
			util_background:bitstring_to_integer(ServerID0)
	end,

	ProductName =
	case lists:keyfind(<<"product_name">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma product_name missing"),
			throw({error, "parma product_name missing"});
		{_, ProductName0} ->
			ProductName0
	end,

	ProductID =
	case lists:keyfind(<<"product_id">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma product_id missing"),
			throw({error, "parma product_id missing"});
		{_, ProductID0} ->
			ProductID0
	end,

	PrivateData = 
	case lists:keyfind(<<"private_data">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma private_data missing"),
			throw({error, "parma private_data missing"});
		{_, PrivateData0} ->
			PrivateData0
	end,

	ChannelNumber =
	case lists:keyfind(<<"channel_number">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma channel_number missing"),
			throw({error, "parma channel_number missing"});
		{_, ChannelNumber0} ->
			util_background:bitstring_to_integer(ChannelNumber0)
	end,

	Source =
	case lists:keyfind(<<"source">>, 1, ContentList) of
		false ->
			<<>>;
		{_, Source0} ->
			Source0
	end,

	Sign =
	case lists:keyfind(<<"sign">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma sign missing"),
			throw({error, "parma sign missing"});
		{_, Sign0} ->
			Sign0
	end,

	EnhancedSign =
	case lists:keyfind(<<"enhanced_sign">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma enhanced_sign missing"),
			throw({error, "parma enhanced_sign missing"});
		{_, EnhancedSign0} ->
			EnhancedSign0
	end,
	
	% 校验KEY
	case util_background:check_recharge_sign_4_anysdk(lists:sort(ContentList)) of
		{false, ClientSign, ServerSign} ->
			?ERR(?MODULE, "sign not match, ClientSign=~p, ServerSign=~p", [ClientSign, ServerSign]),
			throw({error, "check sign fail"});
		true ->
			ok
	end,

	%% 金额处理
	OriRechargeMoney =
	case binary:match(Amount, <<".">>) of
		nomatch ->
			binary_to_integer(Amount);
		{_, _} ->
			binary_to_float(Amount)
	end,

	case PrivateData of
		<<>> ->
			InnerRechargeID0 = mod_recharge:get_inner_recharge_id(GameUserID, round(OriRechargeMoney)),
			InnerRechargeID = list_to_binary(InnerRechargeID0);
		_ ->
			InnerRechargeID = PrivateData,
			OrderServerID = g_recharge:get_server_id(InnerRechargeID),

			MerServerList = 
			case application:get_env(mgserver, merge_server_list) of
				undefined ->
					lists:delete(0, [OrderServerID]);
				{ok, MerServerList0} ->
					lists:delete(0, [OrderServerID|MerServerList0])
			end,

			case  lists:member(ServerID, MerServerList) of
				false ->
					?ERR(?MODULE, "server not match,server_id=~p,acept_server_list=~p", [ServerID, MerServerList]),
					throw({error, "server not match"});
				true ->
					ok
			end
	end,

	RechargeStatus =
	case PayStatus of
		1 ->
			0;
		_ ->
			2
	end,

	PlatformID = ChannelNumber,

	OuterRechargeID =
	case Source of
		<<>> ->
			InnerRechargeID;
		_ ->  %% TODO 根据平台信息获取外部订单号
			?ERR(?MODULE, "source = ~p",[Source]),
			try
				get_outer_recharge_id(Source, ChannelNumber, InnerRechargeID)
			catch ErrCode:ErrMsg ->
				?ERR(?MODULE, "ErrCode = ~p, ErrMsg = ~p",[ErrCode,ErrMsg]),
				InnerRechargeID
			end
	end,

	%% 充值
	Recharge =
	#recharge{
				inner_recharge_id       = InnerRechargeID,
				outer_recharge_id       = OuterRechargeID,
				anysdk_recharge_id      = OrderID,
				account_id              = GameUserID,
				platform_id             = PlatformID,
				server_id               = ServerID,
				suid                    = UserID,
				ori_recharge_money_type = <<"RMB">>,
				ori_recharge_money      = OriRechargeMoney,
				recharge_money          = 0,
				rec_recharge_gold       = 0,
				ori_recharge_gold       = 0,
				recharge_item           = <<>>,
				recharge_channel        = OrderType,
				recharge_status         = RechargeStatus,
				recharge_ext_info       = Source,
				recharge_time           = PayTime
	},

	case catch g_recharge:recharge(Recharge) of
		ok ->
			{ok, "ok"};
		{error, <<"PLATFORM_NOTIFY_RECHARGE_FAIL">>} ->
			{ok, "ok"};
		{error, <<"USER_NOT_EXIST">>} ->
			?ERR(?MODULE, "user not exist, Recharge=~p", [Recharge]),
			throw({error, "user not exist"});
		{error, <<"REPEAT_ORDER">>} ->
			?ERR(?MODULE, "repeat order, Recharge=~p", [Recharge]),
			{ok, "ok"};
		{error, Other} ->
			?ERR(?MODULE, "other error : ~p, Recharge=~p", [Other, Recharge]),
			throw({error, "other error"})
	end.

get_outer_recharge_id(Source, ?PF_IOS_KUAIYONG, OrderID) ->
	{struct, DataList} = mochijson2:decode(Source),
	case lists:keyfind(<<"orderid">>, 1, DataList) of
		false ->
			OrderID;
		{_, OrderID0} ->
			OrderID0
	end;
get_outer_recharge_id(Source, _, OrderID) -> OrderID.