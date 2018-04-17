-module(recharge_notify_4_yyios_pp).

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

	BillNo =
	case lists:keyfind(<<"billno">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma billno missing"),
			throw({error, "parma billno missing"});
		{_, BillNo0} ->
			BillNo0
	end,

	Account =
	case lists:keyfind(<<"account">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma account missing"),
			throw({error, "parma account missing"});
		{_, Account0} ->
			Account0
	end,

	Amount =
	case lists:keyfind(<<"amount">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma amount missing"),
			throw({error, "parma amount missing"});
		{_, Amount0} ->
			Amount0
	end,

	Status =
	case lists:keyfind(<<"status">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma status missing"),
			throw({error, "parma status missing"});
		{_, Status0} ->
			util_background:bitstring_to_integer(Status0)
	end,

	AppID =
	case lists:keyfind(<<"app_id">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma app_id missing"),
			throw({error, "parma app_id missing"});
		{_, AppID0} ->
			AppID0
	end,


	UUID =
	case lists:keyfind(<<"uuid">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma uuid missing"),
			throw({error, "parma uuid missing"});
		{_, UUID0} ->
			UUID0
	end,
	
	RoleID =
	case lists:keyfind(<<"roleid">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma roleid missing"),
			throw({error, "parma roleid missing"});
		{_, RoleID0} ->
			util_background:bitstring_to_integer(RoleID0)
	end,

	Zone =
	case lists:keyfind(<<"zone">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma zone missing"),
			throw({error, "parma zone missing"});
		{_, Zone0} ->
			util_background:bitstring_to_integer(Zone0)
	end,

	Sign =
	case lists:keyfind(<<"sign">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma sign missing"),
			throw({error, "parma sign missing"});
		{_, Sign0} ->
			Sign0
	end,
	
	% 校验KEY
	DataList = 
	case util_background:check_recharge_sign_4_yyios_pp(Sign) of
		{struct, DataList0} ->
			DataList0;
		Other0 ->
			?ERR(?MODULE, "check sign fail, Other0 = ~p", [Other0]),
			throw({error, "check sign fail"})
	end,

	?ERR(?MODULE, "DataList = ~p", [DataList]),

	case lists:keyfind(<<"order_id">>, 1, DataList) of
		false ->
			?ERR(?MODULE, "parma order_id missing"),
			throw({error, "parma order_id missing"});
		{_, OrderID00} when is_integer(OrderID00) ->
			case integer_to_binary(OrderID00) == OrderID of
				true ->
					ok;
				false ->
					throw({error, "parma order_id not_match"})
			end;
		{_, OrderID00} when is_binary(OrderID00) ->
			case OrderID00 == OrderID of
				true ->
					ok;
				false ->
					throw({error, "parma order_id not_match"})
			end;
		_ ->
			throw({error, "parma order_id not_match"})
	end,

	case lists:keyfind(<<"billno">>, 1, DataList) of
		false ->
			?ERR(?MODULE, "parma billno missing"),
			throw({error, "parma billno missing"});
		{_, BillNo} ->
			ok;
		_ ->
			throw({error, "parma billno not_match"})
	end,

	case lists:keyfind(<<"account">>, 1, DataList) of
		false ->
			?ERR(?MODULE, "parma account missing"),
			throw({error, "parma account missing"});
		{_, Account} ->
			Account;
		_ ->
			throw({error, "parma billno not_match"})
	end,

	case lists:keyfind(<<"amount">>, 1, DataList) of
		false ->
			?ERR(?MODULE, "parma amount missing"),
			throw({error, "parma amount missing"});
		{_, Amount} ->
			Amount;
		_ ->
			throw({error, "parma amount not_match"})
	end,

	case lists:keyfind(<<"status">>, 1, DataList) of
		false ->
			?ERR(?MODULE, "parma status missing"),
			throw({error, "parma status missing"});
		{_, Status00} when is_integer(Status00) ->
			case Status00 == Status of
				true ->
					ok;
				false ->
					throw({error, "parma status not_match"})
			end;
		{_, Status00} when is_binary(Status00) ->
			case binary_to_integer(Status00) == Status of
				true ->
					ok;
				false ->
					throw({error, "parma status not_match"})
			end;
		_ ->
			throw({error, "parma status not_match"})
	end,

	case lists:keyfind(<<"app_id">>, 1, DataList) of
		false ->
			?ERR(?MODULE, "parma app_id missing"),
			throw({error, "parma app_id missing"});
		{_, AppID00} when is_integer(AppID00) ->
			case integer_to_binary(AppID00) == AppID of
				true ->
					ok;
				false ->
					throw({error, "parma app_id not_match"})
			end;
		{_, AppID00} when is_binary(AppID00) ->
			case AppID00 == AppID of
				true ->
					ok;
				false ->
					throw({error, "parma app_id not_match"})
			end;
		_ ->
			throw({error, "parma app_id not_match"})
	end,

	case lists:keyfind(<<"uuid">>, 1, DataList) of
		false ->
			?ERR(?MODULE, "parma uuid missing"),
			throw({error, "parma uuid missing"});
		{_, UUID} ->
			UUID;
		_ ->
			throw({error, "parma uuid not_match"})
	end,

	case lists:keyfind(<<"roleid">>, 1, DataList) of
		false ->
			?ERR(?MODULE, "parma roleid missing"),
			throw({error, "parma roleid missing"});
		{_, DataRoleID0} ->
			util_background:bitstring_to_integer(DataRoleID0)
	end,

	DataZone =
	case lists:keyfind(<<"zone">>, 1, ContentList) of
		false ->
			?ERR(?MODULE, "parma zone missing"),
			throw({error, "parma zone missing"});
		{_, DataZone00} when is_integer(DataZone00) ->
			case DataZone00 == Zone of
				true ->
					ok;
				false ->
					throw({error, "parma zone not_match"})
			end;
		{_, DataZone00} when is_binary(DataZone00) ->
			case binary_to_integer(DataZone00) == Zone of
				true ->
					ok;
				false ->
					throw({error, "parma zone not_match"})
			end;
		_ ->
			throw({error, "parma zone not_match"})
	end,

	%% 金额处理
	OriRechargeMoney =
	case binary:match(Amount, <<".">>) of
		nomatch ->
			binary_to_integer(Amount);
		{_, _} ->
			binary_to_float(Amount)
	end,

	case BillNo of
		<<>> ->
			InnerRechargeID0 = mod_recharge:get_inner_recharge_id(RoleID, round(OriRechargeMoney)),
			InnerRechargeID = list_to_binary(InnerRechargeID0),
			[#recharge_info{ server_id=ServerID0,suid=SUID }] = cache:lookup(recharge_info, binary_to_integer(InnerRechargeID)),
			ServerID =
			case Zone =< 0 of
				true ->
					ServerID0;
				false ->
					Zone
			end;
		_ ->
			InnerRechargeID = BillNo,
			OrderServerID = g_recharge:get_server_id(InnerRechargeID),

			[#recharge_info{ server_id=ServerID0,suid=SUID }] = cache:lookup(recharge_info, binary_to_integer(InnerRechargeID)),

			MerServerList = 
			case application:get_env(mgserver, merge_server_list) of
				undefined ->
					lists:delete(0, [OrderServerID]);
				{ok, MerServerList0} ->
					lists:delete(0, [OrderServerID|MerServerList0])
			end,

			ServerID =
			case Zone =< 0 of
				true ->
					ServerID0;
				false ->
					Zone
			end,

			case  lists:member(ServerID, MerServerList) of
				false ->
					?ERR(?MODULE, "server not match,server_id=~p,acept_server_list=~p", [ServerID, MerServerList]),
					throw({error, "server not match"});
				true ->
					ok
			end
	end,

	PlatformID = ?PF_IOS_PP,

	%% 充值
	Recharge =
	#recharge{
				inner_recharge_id       = InnerRechargeID,
				outer_recharge_id       = OrderID,
				account_id              = RoleID,
				platform_id             = PlatformID,
				server_id               = ServerID,
				suid                    = SUID,
				ori_recharge_money_type = <<"RMB">>,
				ori_recharge_money      = OriRechargeMoney,
				recharge_money          = 0,
				rec_recharge_gold       = 0,
				ori_recharge_gold       = 0,
				recharge_item           = <<>>,
				recharge_status         = Status,
				recharge_time           = util:unixtime()
	},

	case catch g_recharge:recharge(Recharge) of
		ok ->
			{ok, "success"};
		{error, <<"PLATFORM_NOTIFY_RECHARGE_FAIL">>} ->
			{ok, "success"};
		{error, <<"USER_NOT_EXIST">>} ->
			?ERR(?MODULE, "user not exist, Recharge=~p", [Recharge]),
			throw({error, "user not exist"});
		{error, <<"REPEAT_ORDER">>} ->
			?ERR(?MODULE, "repeat order, Recharge=~p", [Recharge]),
			{ok, "success"};
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