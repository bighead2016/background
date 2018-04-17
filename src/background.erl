%% Feel free to use, reuse and abuse the code in this file.

%% @doc GET echo handler.
-module(background).

-include("log.hrl").

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
	?DBG(?MODULE, "background init"),
	{ok, Req, undefined}.

handle(Req, State) ->
	%% 读取客户端IP
	{Peer, _} = cowboy_req:peer(Req),
	?DBG(?MODULE, "Peer=~p", [Peer]),
	%% 读取请求的路径（即模块名）
	{[Path], Req1} = cowboy_req:path_info(Req),
	ModName1 = erlang:binary_to_list(Path),
	?DBG(?MODULE, "ModName=~p", [ModName1]),
	%% 读取HTTP读写方式
	{Method, Req2} = cowboy_req:method(Req1),
  	?DBG(?MODULE, "Method=~p", [Method]),
  	%% 读取请求内容
	case cowboy_req:qs_vals(Req2) of
		{undefined, Req3} ->
			{ok, Req4} = cowboy_req:reply(400, [], <<"Missing echo parameter.">>, Req3);
		{ContentList, Req3} ->
			ModName = util:string_to_term(ModName1),
			?ERR(?MODULE, "ModName=~p, ContentList=~p", [ModName, ContentList]),

			case catch ModName:handle(ContentList) of
				{error, {struct, List}} ->
					Reply = mochijson2:encode({struct, List}),
					{ok, Req4} = cowboy_req:reply(200,
								[{<<"Content-Type">>, <<"application/json">>}], Reply, Req3);
				{struct, List}->
					Reply = mochijson2:encode({struct, List}),
					{ok, Req4} = cowboy_req:reply(200,
								[{<<"Content-Type">>, <<"application/json">>}], Reply, Req3);
				{error, Result} when is_binary(Result) ->
					{ok, Req4} = cowboy_req:reply(200, [{<<"content-encoding">>, <<"utf-8">>}], Result, Req3);
				{error, Result} when is_list(Result) ->
					{ok, Req4} = cowboy_req:reply(200, [{<<"content-encoding">>, <<"utf-8">>}], unicode:characters_to_binary(Result), Req3);
				Result when is_binary(Result) ->
					{ok, Req4} = cowboy_req:reply(200, [{<<"content-encoding">>, <<"utf-8">>}], Result, Req3);
				Result when is_list(Result) ->
					{ok, Req4} = cowboy_req:reply(200, [{<<"content-encoding">>, <<"utf-8">>}], unicode:characters_to_binary(Result), Req3);
				Result ->
					?ERR(?MODULE, "Result = ~p", [Result]),
					{ok, Req4} = cowboy_req:reply(200, [{<<"content-encoding">>, <<"utf-8">>}], <<"system error">>, Req3)
			end
	end,
	
	{ok, Req4, State}.

terminate(_Reason, _Req, _State) ->
	ok.