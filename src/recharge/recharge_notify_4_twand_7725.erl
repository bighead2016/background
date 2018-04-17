-module(recharge_notify_4_twand_7725).

-include("recharge.hrl").
-include("account.hrl").
-include("log.hrl").

-compile(export_all).
%% "http://192.168.1.3:9999/recharge_notify_4_twand_7725?amount=30&game=1&server=1&gold=320&info=150422000010000001&item=&orderid=1&paytype=&pvc=1&roleid=812&rolename=9100&timestamp=1469280000&userid=f9978ce98e4e40b93e3ceb61a08121ee&sign=758fdd12f141bdd8336df55a41bd7565"
%% SELECT MD5("amount=30game=1server=1gold=320info=150422000010000001item=orderid=1paytype=pvc=1roleid=812rolename=9100timestamp=1469280000userid=f9978ce98e4e40b93e3ceb61a08121eeyudaogserverkeyd2d7a18dfdda829a2f36")

handle(ContentList, Req) ->
	OrderID =
	case lists:keyfind(<<"orderid">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma orderid missing"),
			throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
		{_, OrderID0} ->
			OrderID0
	end,

	UserID =
	case lists:keyfind(<<"userid">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma userid missing"),
			throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
		{_, UserID0} ->
			UserID0
	end,

	RoleID =
	case lists:keyfind(<<"roleid">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma roleid missing"),
			throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
		{_, RoleID0} ->
			util_background:bitstring_to_integer(RoleID0)
	end,

	RoleName =
	case lists:keyfind(<<"rolename">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma rolename missing"),
			throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
		{_, RoleName0} ->
			RoleName0
	end,

	Game =
	case lists:keyfind(<<"game">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma game missing"),
			throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
		{_, Game0} ->
			Game0
	end,

	ServerID =
	case lists:keyfind(<<"server">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma server missing"),
			throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
		{_, ServerID0} ->
			util_background:bitstring_to_integer(ServerID0)
	end,

	Currency = 
	case lists:keyfind(<<"currency">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma currency missing"),
			throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
		{_, Currency0} ->
			Currency0
	end,

	Amount =
	case lists:keyfind(<<"amount">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma amount missing"),
			throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
		{_, Amount0} ->
			Amount0
	end,

	Gold =
	case lists:keyfind(<<"gold">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma gold missing"),
			throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
		{_, Gold0} ->
			util_background:bitstring_to_integer(Gold0)
	end,

	PayType =
	case lists:keyfind(<<"paytype">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma paytype missing"),
			throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
		{_, PayType0} ->
			PayType0
	end,

	Info =
	case lists:keyfind(<<"info">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma info missing"),
			throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
		{_, Info0} ->
			Info0
	end,

	Timestamp =
	case lists:keyfind(<<"timestamp">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma timestamp missing"),
			throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
		{_, Timestamp0} ->
			util_background:bitstring_to_integer(Timestamp0)
	end,

	PVC =
	case lists:keyfind(<<"pvc">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma pvc missing"),
			throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
		{_, PVC0} ->
			PVC0
	end,

	Item =
	case lists:keyfind(<<"item">>, 1, ContentList) of
		false ->
			<<>>;
		{_, Item0} ->
			Item0
	end,

	Sign =
	case lists:keyfind(<<"sign">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma sign missing"),
			throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
		{_, Sign0} ->
			Sign0
	end,

	% 校验KEY
	case util_background:check_recharge_sign_4_twand_7725(ContentList) of
		{false, ClientSign, ServerSign} ->
			?ERR(?MODULE, "sign not match, ClientSign=~p, ServerSign=~p", [ClientSign, ServerSign]),
			throw({error, {struct, [{code, <<"3003">>},{message, <<"SIGN_NOT_MATCH">>}]}});
		true ->
			ok
	end,

	%% 台币:元宝 = 1:2
	RechargeMoney = Gold/2,

	case Info of
		<<>> ->
			InnerRechargeID = mod_recharge:get_inner_recharge_id(RoleID, round(RechargeMoney)),
			Info1 = list_to_binary(InnerRechargeID);
		_ ->
			Info1 = Info,
			OrderServerID = g_recharge:get_server_id(Info),

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
					throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
				true ->
					ok
			end
	end,

	%% 金额处理
	OriRechargeMoney =
	case binary:match(Amount, <<".">>) of
		nomatch ->
			binary_to_integer(Amount);
		{_, _} ->
			binary_to_float(Amount)
	end,

	OriRechargeGold =
	case Item of
		<<"month_card">> ->
			0;
		_ ->
			Gold
	end,

	%% 充值
	Recharge =
	#recharge{
				inner_recharge_id       = Info1,
				outer_recharge_id       = OrderID,
				account_id              = RoleID,
				platform_id             = ?PF_TWAND_7725,
				server_id               = ServerID,
				suid                    = UserID,
				ori_recharge_money_type = Currency,
				ori_recharge_money      = OriRechargeMoney,
				recharge_money          = 0,
				rec_recharge_gold       = Gold,
				ori_recharge_gold       = OriRechargeGold,
				recharge_item           = Item,
				recharge_channel        = PayType,
				recharge_time           = Timestamp
	},

	case catch g_recharge:recharge(Recharge) of
		ok ->
			{ok, {struct, [{code, <<"3">>},{message, <<"SUCCESS">>}]}};
		{error, <<"USER_NOT_EXIST">>} ->
			?ERR(?MODULE, "user not exist, Recharge=~p", [Recharge]),
			throw({error, {struct, [{code, <<"3004">>},{message, <<"USER_NOT_EXIST">>}]}});
		{error, <<"REPEAT_ORDER">>} ->
			?ERR(?MODULE, "repeat order, Recharge=~p", [Recharge]),
			throw({error, {struct, [{code, <<"3006">>},{message, <<"REPEAT_ORDER">>}]}});
		{error, Other} ->
			?ERR(?MODULE, "other error : ~p, Recharge=~p", [Other, Recharge]),
			throw({error, {struct, [{code, <<"3001">>},{message, <<"OTHER_ERROR">>}]}})
	end.