-module(pay_notify_4_apple).

% -include("log.hrl").
% -include("log_type.hrl").
% -include("log_monitor.hrl").
% -include("account.hrl").
% -include("counter.hrl").
% -include("background.hrl").
% -include("pt_activity.hrl").

% -export([init/3]).
% -export([handle/2]).
% -export([terminate/3]).

% init(_Transport, Req, []) ->
% 	{ok, Req, undefined}.

% handle(Req, State) ->

%     %% 读取客户端IP
%     {Peer, _} = cowboy_req:peer(Req),
%     ?DBG(background, "Peer=~p", [Peer]),
%     %% 读取请求内容
%     case cowboy_req:qs_vals(Req) of
%         {undefined, Req1} ->
%         	?ERR(background, "param_error"),
%             Result = <<"fail">>;
%         {ContentList, Req1} ->
%         	OrderIDTuple = lists:keyfind(<<"order_id">>, 1, ContentList),
%         	BillNoTuple = lists:keyfind(<<"billno">>, 1, ContentList),
%         	AccountTuple = lists:keyfind(<<"account">>, 1, ContentList),
%         	AmountTuple = lists:keyfind(<<"amount">>, 1, ContentList),
%         	StatusTuple = lists:keyfind(<<"status">>, 1, ContentList),
%         	AppIDTuple = lists:keyfind(<<"app_id">>, 1, ContentList),
%         	RoleIDTuple = lists:keyfind(<<"roleid">>, 1, ContentList),
%         	ZoneTuple = lists:keyfind(<<"zone">>, 1, ContentList),
%         	SignTuple = lists:keyfind(<<"sign">>, 1, ContentList),
%         	case OrderIDTuple == false orelse BillNoTuple == false orelse AccountTuple == false
%         	  orelse AmountTuple == false orelse StatusTuple == false orelse AppIDTuple == false
%         	  orelse RoleIDTuple == false orelse ZoneTuple == false orelse SignTuple == false of
%         		true ->
%         			?ERR(background, "param_error"),
%         			Result = <<"fail">>;
%         		false ->
% 					%% 检查数据一致性
% 					{_, BillNoStr} = BillNoTuple,
% 					BillNo = util_background:bitstring_to_integer(BillNoStr),
% 					{_, RoleIDStr} = RoleIDTuple,
% 					RoleID = util_background:bitstring_to_integer(RoleIDStr),
% 					% case cache:lookup(pay, BillNo) of
% 					case util_background:check_pay_id(BillNo) of
%                         processing ->
%                             ?ERR(background, "PayID is processing"),
%                             Result = <<"fail">>;
% 						[] ->
% 							?ERR(background, "dealseq not match"),
% 							ets:delete(ets_order, BillNo),
% 							Result = <<"fail">>;
% 						[PayRec] when PayRec#pay.role_id /= RoleID ->
% 							?ERR(background, "role_id not match"),
% 							ets:delete(ets_order, BillNo),
% 							Result = <<"fail">>;
% 						[PayRec] when PayRec#pay.platform_id /= ?PF_APPLE ->
% 							?ERR(background, "platform not match"),
% 							ets:delete(ets_order, BillNo),
% 							Result = <<"fail">>;
% 						[PayRec] when PayRec#pay.status /= 0 ->
% 							?ERR(background, "pay is deal fail"),
% 							ets:delete(ets_order, BillNo),
% 							Result = <<"success">>;
% 						[PayRec] ->
%         					{_, SignStr} = SignTuple,
%         					%% 验证签名正确性(苹果园的跟PP助手的一样，故沿用PP助手的方法)
% 		        			ParseList = util_background:public_decode_4_json(SignStr),
% 		        			case OrderIDTuple == lists:keyfind(<<"order_id">>, 1, ParseList)
% 		        			  orelse BillNoTuple == lists:keyfind(<<"billno">>, 1, ParseList) 
% 		        			  orelse AccountTuple == lists:keyfind(<<"account">>, 1, ParseList)
% 				        	  orelse AmountTuple == lists:keyfind(<<"amount">>, 1, ParseList) 
% 				        	  orelse StatusTuple == lists:keyfind(<<"status">>, 1, ParseList) 
% 				        	  orelse AppIDTuple == lists:keyfind(<<"app_id">>, 1, ParseList)
% 				        	  orelse RoleIDTuple == lists:keyfind(<<"role_id">>, 1, ParseList) 
% 				        	  orelse ZoneTuple == lists:keyfind(<<"zone">>, 1, ParseList) 
% 				        	  orelse SignTuple == lists:keyfind(<<"sign">>, 1, ParseList) of
% 		        				false ->
% 		        					?ERR(background, "sign data prama err"),
% 		        					Result = <<"fail">>;
% 		        				true ->
%         							AccountID = PayRec#pay.role_id,

%         							{_, AccountStr} = AmountTuple,
% 			        				Amount =
% 			        				case string:tokens(binary_to_list(AccountStr), ".") of
% 			        					[] ->
% 			        						0;
% 			        					[I|_] ->
% 			        						list_to_integer(I)
% 			        				end,
% 			        				{IsFirstCharge, ChargeGold, OrigChargeGold} = mod_activity:get_charge_diamond(AccountID, trunc(Amount)),
% 	        						% {IsFirstCharge, ChargeGold} = mod_activity:get_charge_diamond(AccountID, Amount),

%         							case StatusTuple of
%         								{_, <<"0">>} ->
%         									OrderStatus = 1;
%         									% mod_economy:add(AccountID, [{diamond, ChargeGold}], ?FROM_CHARGE),
% 											% mod_activity:update_charge_times(AccountID, OrigChargeGold),
%            %                                  mod_per_counter:add(AccountID, ?PER_COUNTER_TYPE_CHARGE_MONEY, trunc(Amount)),
%            %                                  mod_vip:check_vip_levelup(AccountID, ChargeGold),
% 											% case IsFirstCharge of
% 											% 	true ->
% 											% 		sender:send(AccountID, #pt_activity_is_first_charge_4203_o{ is_first_charge=0 });
% 											% 	false ->
% 											% 		skip
% 											% end;
% 										{_, <<"1">>} ->
% 											OrderStatus = 1;
% 											% mod_economy:add(AccountID, [{diamond, ChargeGold}], ?FROM_CHARGE),
% 											% mod_activity:update_charge_times(AccountID, OrigChargeGold),
%            %                                  mod_per_counter:add(AccountID, ?PER_COUNTER_TYPE_CHARGE_MONEY, trunc(Amount)),
%            %                                  mod_vip:check_vip_levelup(AccountID, ChargeGold),
% 											% case IsFirstCharge of
% 											% 	true ->
% 											% 		sender:send(AccountID, #pt_activity_is_first_charge_4203_o{ is_first_charge=0 });
% 											% 	false ->
% 											% 		skip
% 											% end;
% 										_ ->
% 											OrderStatus = 2
% 									end,

% 									{_, OutOrderIDStr} = OrderIDTuple,
% 									% OutOrderID = util_background:bitstring_to_integer(OutOrderIDStr),

% 									%% 去中心服检查外部订单是否已经存在，不存在返回true,存在返回false
%                                     {ok, CenterNode} = application:get_env(background, oceanus_state_node),
                                    
%                                     PlatformID = ?PF_APPLE,
%                                     PlatformName = util_oceanus:get_platform_name(PlatformID),
%                                     PlatformShortName = util_oceanus:get_platform_shot_name(PlatformID),
%                                     AccountRec = mod_account:lookup_account(PayRec#pay.role_id),
%                                     case catch rpc:call(CenterNode, g_out_pay_server, check_out_pay_id, [PlatformID,PlatformName,PlatformShortName,OutOrderIDStr,PayRec#pay.suid,Amount,OrderStatus,AccountRec#account.server_id,ChargeGold]) of
%                                         true ->

											

% 											LogPayRec = #log_pay{
% 																pay_id = BillNo,
% 																out_order_id = OutOrderIDStr,
% 																platform_id = ?PF_APPLE,
% 		                                                        platform_name = util_oceanus:get_platform_shot_name(?PF_APPLE),
% 																platform = <<"苹果园">>,
% 																role_id = AccountID,
% 																account_name = AccountRec#account.name,
% 																server_id = AccountRec#account.server_id,
% 																dim_level = AccountRec#account.level,
% 																pay_type = 0,
% 																pay_money = Amount,
% 																pay_gold = ChargeGold,
% 																status = OrderStatus,
% 																happend_time = util:unixtime()
% 																},
% 											log_monitor:write_user_log(LogPayRec),

% 											NewPayRec = PayRec#pay{
% 														out_order_id = OutOrderIDStr,
% 		                                                platform_name = util_oceanus:get_platform_shot_name(?PF_APPLE),
% 														platform = <<"苹果园">>,
% 														pay_type = 0,
% 														pay_money = Amount,
% 														pay_gold = ChargeGold,
% 														status = OrderStatus,
% 														happend_time = util:unixtime()
% 														},
% 											cache:update(NewPayRec),

% 											case StatusTuple of
% 		        								{_, <<"0">>} ->
% 		        									g_charge:do_charge(AccountID, Amount, IsFirstCharge, ChargeGold, OrigChargeGold, ?FROM_CHARGE);
% 												{_, <<"1">>} ->
% 													g_charge:do_charge(AccountID, Amount, IsFirstCharge, ChargeGold, OrigChargeGold, ?FROM_CHARGE);
% 												_ ->
% 													skip
% 											end,

% 											Result = <<"success">>;
% 										_ ->
% 											?ERR(background, "pay is repeat, platform_id=~p, out_order_id=~p", [PlatformID, OutOrderIDStr]),
%                                             Result = <<"fail">>
%                                     end
% 							end,
% 							ets:delete(ets_order, BillNo)
% 					end
% 			end
%     end,
%     {_, Req2} = cowboy_req:reply(200, [{<<"content-encoding">>, <<"utf-8">>}], Result, Req1),
% 	{ok, Req2, State}.

% terminate(_Reason, _Req, _State) ->
% 	ok.