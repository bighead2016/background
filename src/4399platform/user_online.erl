-module(user_online).

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
            Result = <<"-1">>;
        {ContentList, Req1} ->
            GameIDTuple = lists:keyfind(<<"game_id">>, 1, ContentList),
            ServerIDTuple = lists:keyfind(<<"server_id">>, 1, ContentList),
            PlatformIDTuple = lists:keyfind(<<"platform_id">>, 1, ContentList),
            TimeTuple = lists:keyfind(<<"time">>, 1, ContentList),
            FlagTuple = lists:keyfind(<<"flag">>, 1, ContentList),
            case GameIDTuple == false orelse ServerIDTuple == false orelse PlatformIDTuple == false
              orelse TimeTuple == false orelse FlagTuple == false of
                true ->
                    Result = <<"-1">>;
                false ->
                    case util_background:check_tick_4_4399_plat(user_online,[FlagTuple,GameIDTuple,ServerIDTuple,PlatformIDTuple,TimeTuple]) of
                        false ->
                            Result = <<"-2">>;
                        true ->
                            Sql = "Select Max(people),min(people) FROM log_online WHERE Date(log_time) = CURDATE()",
                            case catch log_sql_operator:do_execute(Sql) of
                                {ok, [[MaxNum, MinNum]]} ->
                                    CurrNum = case ets:info(ets_online, size) of
                                        undefined -> 0;
                                        OL -> OL
                                    end,
                                    Result = list_to_binary(lists:flatten(io_lib:format("~w,~w,~w",[CurrNum, MaxNum, MinNum])));
                                _ ->
                                    Result = <<"0">>
                            end
                    end
            end
    end,
    {_, Req2} = cowboy_req:reply(200, [{<<"content-encoding">>, <<"utf-8">>}], Result, Req1),
	{ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.