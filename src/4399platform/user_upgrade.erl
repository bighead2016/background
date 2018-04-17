-module(user_upgrade).

-include("log.hrl").

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
            ?ERR(account, "i am hehe undefine~p", [Req1]),
            {_, Req2} = cowboy_req:reply(200, [{<<"content-encoding">>, <<"utf-8">>}], <<"-1">>, Req1);
        {ContentList, Req1} ->
            GameIDTuple = lists:keyfind(<<"game_id">>, 1, ContentList),
            ServerIDTuple = lists:keyfind(<<"server_id">>, 1, ContentList),
            PlatformIDTuple = lists:keyfind(<<"platform_id">>, 1, ContentList),
            TimeTuple = lists:keyfind(<<"time">>, 1, ContentList),
            FlagTuple = lists:keyfind(<<"flag">>, 1, ContentList),

            StartTimeTuple = lists:keyfind(<<"start_time">>, 1, ContentList),
            EndTimeTuple = lists:keyfind(<<"end_time">>, 1, ContentList),

            case GameIDTuple == false orelse ServerIDTuple == false orelse PlatformIDTuple == false orelse TimeTuple == false
              orelse FlagTuple == false orelse StartTimeTuple == false orelse EndTimeTuple == false of
                true ->
                    ?ERR(account, "i am hehe true~p", [Req1]),
                    {_, Req2} = cowboy_req:reply(200, [{<<"content-encoding">>, <<"utf-8">>}], <<"-1">>, Req1);
                false ->
                    case util_background:check_tick_4_4399_plat(user_upgrade,
                    	[FlagTuple,StartTimeTuple,EndTimeTuple,GameIDTuple,ServerIDTuple,PlatformIDTuple,TimeTuple]) of
                        false ->
                            {_, Req2} = cowboy_req:reply(200, [{<<"content-encoding">>, <<"utf-8">>}], <<"-2">>, Req1);
                        true ->
                        	{_, StartTimeStr} = StartTimeTuple,
                        	{_, EndTimeStr} = EndTimeTuple,
                        	StartTime = util_background:bitstring_to_integer(StartTimeStr),
                        	EndTime = util_background:bitstring_to_integer(EndTimeStr),

                            % Sql = io_lib:format(
                            % 	"Select role_id,suid,last_level,current_level,happend_time FROM log_level_up WHERE platform_id=19 AND spirit_id=0 AND current_level>last_level and happend_time between ~p and ~p", 
                            % 	[StartTime, EndTime]
                            % 	),
                            % ?DBG(background, "Sql = ~s", [Sql]),
                            % case catch log_sql_operator:do_execute(Sql) of
                            %     {ok, RoleList} ->
                            %         ?ERR(account, "RoleList = ~p", [RoleList]),
                            %         Result = paseResult(RoleList),
                            %         Reply = mochijson2:encode(Result),
                            %         ?ERR(account, "Reply = ~p", [Reply]),
                            %         {ok, Req2} = cowboy_req:reply(200, [{<<"Content-Type">>, <<"application/json">>}], Reply, Req1);
                            %     _ ->
                            %         {_, Req2} = cowboy_req:reply(200, [{<<"content-encoding">>, <<"utf-8">>}], <<"0">>, Req1)
                            % end
                            Sql = "Select role_id,suid,last_level,current_level,happend_time FROM log_level_up WHERE log_time between ? AND ? AND platform_id=? AND spirit_id=? AND current_level>last_level",

                            case catch emysql:execute(oceanus_pool, Sql, [util:unixtime_to_timestamp(StartTime), util:unixtime_to_timestamp(EndTime), 19, 0]) of
                                {result_packet,_,_,RoleList,_} ->
                                    ?DBG(background, "RoleList = ~p", [RoleList]),
                                    Result = paseResult(RoleList),
                                    Reply = mochijson2:encode(Result),
                                    ?DBG(background, "Reply = ~p", [Reply]),
                                    {ok, Req2} = cowboy_req:reply(200, [{<<"Content-Type">>, <<"application/json">>}], Reply, Req1);
                                _ ->
                                    ?DBG(background, "Sql=~s", [Sql]),
                                    {_, Req2} = cowboy_req:reply(200, [{<<"content-encoding">>, <<"utf-8">>}], <<"0">>, Req1)
                            end
                    end
            end
    end,
    
	{ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.

paseResult([[RoleID, SUID, LastLevel, CurrLevel, UpgradeTime]|Rest]) ->
	case catch mod_account:get_player_name(RoleID) of
		RoleName when is_binary(RoleName) ->
            LevelList = lists:seq(LastLevel+1, CurrLevel),
			F = fun(Lv) ->
                [SUID, RoleName, Lv, UpgradeTime]
            end,
            RsultList = lists:map(F, LevelList),
			RestResult = paseResult(Rest),
			RsultList ++ RestResult;
		_ ->
			paseResult(Rest)
	end;
paseResult([]) ->
	[].