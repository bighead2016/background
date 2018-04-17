-module(pay).

-include("log.hrl").
-include("log_type.hrl").
% -include("log_monitor.hrl").
-include("account.hrl").
-include("counter.hrl").
-include("background.hrl").

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
	{ok, Req, undefined}.

handle(Req, State) ->

    %% 读取客户端IP
    {Peer, _} = cowboy_req:peer(Req),
    ?DBG(background, "Peer=~p", [Peer]),
    %% 读取请求内容
    case cowboy_req:qs_vals(Req) of
        {undefined, Req1} ->
            Result = <<"-1">>;
        {ContentList, Req1} ->
        	OrderIDTuple = lists:keyfind(<<"order_id">>, 1, ContentList),
            GameIDTuple = lists:keyfind(<<"game_id">>, 1, ContentList),
            ServerIDTuple = lists:keyfind(<<"server_id">>, 1, ContentList),
            PlatfromIDTuple = lists:keyfind(<<"platform_id">>, 1, ContentList),
            UIDTuple = lists:keyfind(<<"uid">>, 1, ContentList),
            PayWayTuple = lists:keyfind(<<"pay_way">>, 1, ContentList),
            AmountTuple = lists:keyfind(<<"amount">>, 1, ContentList),
            CallBackTuple = lists:keyfind(<<"callback_info">>, 1, ContentList),
            OrderStatusTuple = lists:keyfind(<<"order_status">>, 1, ContentList),
            FailedDescTuple = lists:keyfind(<<"failed_desc">>, 1, ContentList),
            SignTuple = lists:keyfind(<<"sign">>, 1, ContentList),

            case OrderIDTuple == false orelse GameIDTuple == false orelse ServerIDTuple == false
              orelse UIDTuple == false orelse PayWayTuple == false orelse AmountTuple == false
              orelse CallBackTuple == false orelse OrderStatusTuple == false orelse FailedDescTuple == false
              orelse SignTuple == false of
                true ->
                    Result = <<"-1">>;
                false ->
                	{_, ServerIDStr} = ServerIDTuple,
		            ServerID = util_background:bitstring_to_integer(ServerIDStr),
		            {ok, LocalServerList} = application:get_env(hosted_server_indexes),
		            % LocalServerID = oceanus_config:get(server_index),
		            case lists:member(ServerID, LocalServerList) of
		            	false ->
		            		Result = <<"-1">>;
		            	true ->
		                	{_, SignStr} = SignTuple,
		                	FlagTuple = {<<"flag">>, SignStr},
		                    case util_background:check_tick_4_4399_plat(pay,
		                    											[FlagTuple,OrderIDTuple,GameIDTuple,ServerIDTuple,UIDTuple,
		                    											PayWayTuple,AmountTuple,CallBackTuple,OrderStatusTuple,FailedDescTuple]
		                    											) of
		                        false ->
		                            Result = <<"-2">>;
		                        true ->
		                        	{_, UIDStr} = UIDTuple,
		                        	SUID = util_background:bitstring_to_integer(UIDStr),
		                        	PlatfromID =
				                	case PlatfromIDTuple of
				                		{_, PlatformIDStr} when PlatformIDStr /= <<"1">> ->
				                			Sql1 = "SELECT id FROM gd_Account WHERE platform=? AND server_id=? AND name=?",
				                			% AccountID = SUID,
				                			util_background:bitstring_to_integer(PlatformIDStr);
				                		{_, PlatformIDStr} ->
				                			Sql1 = "SELECT id FROM gd_Account WHERE platform=? AND server_id=? AND suid=?",
				                			1
				                	end,
				                	case emysql:execute(oceanus, Sql1, [PlatfromID, ServerID, SUID]) of
		                				{result_packet,_,_,[[AccountID]],_} ->
		                					skip;
		                				_ ->
		                					AccountID = 0
		                			end,
		                        	
		                        	case catch mod_account:lookup_account(AccountID) of
		                        		AccountRec when is_record(AccountRec, account) ->
				                        	{_, OrderIDStr} = OrderIDTuple,
				                        	OutOrderID = binary_to_list(OrderIDStr),
				                            Sql = io_lib:format("SELECT COUNT(1) from log_pay WHERE out_order_id='~s'",[OutOrderID]),
				                            case catch log_sql_operator:do_execute(Sql) of
				                                {ok, [[Count]]} when Count < 1 ->
				                                	% {_, ServerIDStr} = ServerIDTuple,
				                                	% ServerID = util_background:bitstring_to_integer(ServerIDStr),
				                                    {_, PayWayStr} = PayWayTuple,
				                                    PayWay = util_background:bitstring_to_integer(PayWayStr),
				                                    {_, AmountStr} = AmountTuple,
				                                    Amount = util_background:bitstring_to_integer(AmountStr),
				                                    {_, CallBackStr} = CallBackTuple,
				                                    CallBack = binary_to_list(CallBackStr),
				                                    {_, FailedDescStr} = FailedDescTuple,
				                                    FailedDesc = binary_to_list(FailedDescStr),

                                                    {_, ChargeGold, OrigChargeGold} = mod_activity:get_charge_diamond(AccountID, Amount),
													case OrderStatusTuple of
														{_, <<"S">>} ->
															OrderStatus = 1,
															mod_economy:add(AccountID, [{diamond, ChargeGold}], ?FROM_RECHARGE),
                                                            mod_activity:update_charge_times(AccountID, OrigChargeGold),
                                                            % OldTotalDiamond = mod_per_counter:get(AccountID, ?PER_COUNTER_TYPE_CHARGE_DIAMOND),
                                                            mod_per_counter:add(AccountID, ?COUNTER_TYPE_RECHARGE_MONEY, trunc(Amount)),
                                                            mod_vip:check_vip_levelup(AccountID, ChargeGold);
                                                            % mod_per_counter:add(AccountID, ?PER_COUNTER_TYPE_CHARGE_DIAMOND, ChargeGold);
														{_, <<"F">>} ->
															OrderStatus = 2
													end,
													% LogPayRec = #log_pay{
													% 					out_order_id = OutOrderID,
													% 					platform = "4399",
													% 					role_id = AccountID,
													% 					account_name = AccountRec#account.name,
													% 					server_id = ServerID,
													% 					dim_level = AccountRec#account.level,
													% 					pay_type = 0,
													% 					pay_money = Amount,
													% 					pay_gold = ChargeGold,
													% 					status = OrderStatus,
													% 					happend_time = util:unixtime()
													% 					},
													% log_monitor:write_user_log(LogPayRec),

													PayRec = #pay{
																pay_id = g_uid:get(pay),
																out_order_id = OutOrderID,
																platform = "4399",
																role_id = AccountID,
																account_name = AccountRec#account.account,
																server_id = ServerID,
																dim_level = AccountRec#account.level,
																pay_type = 0,
																pay_money = Amount,
																pay_gold = ChargeGold,
																status = OrderStatus,
																happend_time = util:unixtime()
																},
													cache:insert(PayRec),

				                                    Result = <<"1">>;
				                                {ok, [[Count]]} ->
				                                	Result = <<"2">>;
				                                Other ->
				                                	?ERR(background, "ErrMsg = ~p", [Other]),
				                                    Result = <<"0">>
				                            end;
				                        _ ->
				                        	Result = <<"-3">>
				                    end
		                    end
		            end
            end
    end,
    {_, Req2} = cowboy_req:reply(200, [{<<"content-encoding">>, <<"utf-8">>}], Result, Req1),
	{ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.
