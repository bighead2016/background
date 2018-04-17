-module(online_info).

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
%     OnlineIDList = ets:tab2list(ets_online),
%     Num = length(OnlineIDList),
% 	F = fun({ID, _Pid}) ->
% 		Account = mod_account:lookup_account(ID),
% 		[ID, Account#account.name]
% 	end,
% 	OnlineList = lists:map(F, OnlineIDList),

% 	Reply = mochijson2:encode({struct, [{online_num, Num}, {data, OnlineList}]}),

%     {ok, Req1} = cowboy_req:reply(200, [{<<"Content-Type">>, <<"application/json">>}], Reply, Req),
% 	{ok, Req1, State}.

% terminate(_Reason, _Req, _State) ->
% 	ok.