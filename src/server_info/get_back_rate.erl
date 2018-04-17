-module(get_back_rate).

% -include("log.hrl").
% -include("log_type.hrl").
% -include("log_monitor.hrl").
% -include("account.hrl").
% -include("counter.hrl").

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
%             FromRecNum = 0,
%             ToRecNum = 30,
%             WhereCond = "",
%             LimitCond = "LIMIT ?,?";
%         {ContentList, Req1} ->
%         	case lists:keyfind(<<"begindate">>, 1, ContentList) of
%         		{<<"begindate">>, BeginDateStr} when BeginDateStr /= <<>> ->
%         			case lists:keyfind(<<"enddate">>, 1, ContentList) of
%         				{<<"enddate">>, EndDateStr} when EndDateStr /= <<>> ->
%         					FromRecNum = BeginDateStr,
%         					ToRecNum = EndDateStr,
%         					WhereCond = "WHERE stat_date BETWEEN ? AND ?",
%         					LimitCond = "";
%         				_ ->
%         					FromRecNum = 0,
% 				            ToRecNum = 30,
% 				            WhereCond = "",
% 				            LimitCond = "LIMIT ?,?"
% 				    end;
%         		_ ->
%         			FromRecNum = 0,
% 		            ToRecNum = 30,
% 		            WhereCond = "",
% 		            LimitCond = " LIMIT ?,?"
% 		    end
% 	end,

% 	{ok, StatDBName} = application:get_env(background, db_stat_name),

% 	Sql = io_lib:format("SELECT stat_date,stat_IPTotNum,stat_IPBackNum,stat_IPBackRate,stat_AccountTotNum,stat_AccountBackNum,stat_AccountBackRate FROM ~s.stat_backrate ~s ORDER BY stat_date DESC ~s",
% 						[StatDBName, WhereCond,LimitCond]),
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

% 	Reply = mochijson2:encode({struct, [Status, Data]}),

%     {ok, Req2} = cowboy_req:reply(200, [{<<"Content-Type">>, <<"application/json">>}], Reply, Req1),
% 	{ok, Req2, State}.

% terminate(_Reason, _Req, _State) ->
% 	ok.

% paseResult([[{date, {Y,M,D}},IPTotNum,IPBackNum,IPBackRate,AccountTotNum,AccountBackNum, AccountBackRate]|RestList]) -> 
% 	DateStr = list_to_binary(integer_to_list(Y) ++ integer_to_list(M) ++ integer_to_list(D)),
% 	Result = {struct, [
% 						{<<"日期          ">>, DateStr},{<<"首日IP总数    ">>, IPTotNum},{<<"当日IP回访数  ">>, IPBackNum},{<<"IP回访率      ">>, IPBackRate},
% 						{<<"首日账号总数  ">>, AccountTotNum}, {<<"当日账号回访数">>, AccountBackNum},{<<"账号回访率    ">>, AccountBackRate}
% 					]},
% 	RestResult = paseResult(RestList),
% 	[Result|RestResult];
% paseResult([]) ->
% 	[].
