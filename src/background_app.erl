%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(background_app).
-behaviour(application).

-include("log.hrl").

%% API.
-export([start/2]).
-export([stop/1]).
-export([get_cowboy_routes/0, reload_cowboy_routes/0]).

%% API.

start(_Type, _Args) ->
	?DBG(background, "background start"),
	Dispatch = cowboy_router:compile(get_cowboy_routes()),
    {ok, BGPort} = application:get_env(background, background_port),
	case cowboy:start_http(http, 10, [{port, BGPort}], [{env, [{dispatch, Dispatch}]}]) of
		{ok, _} -> void;
		_Other -> ?ERR(background, "_Other = ~p", [_Other])
	end,
	background_sup:start_link().

stop(_State) ->
	ok.

get_cowboy_routes() ->
    [
     {'_', [
            {"/monitor/ping", ping_handler, []},
            {"/monitor/gen_cluster_info/[...]", cluster_info_handler, []},
            {"/monitor/log/[...]", cowboy_static, [{directory, "log/"}]},
            {"/background/[...]", background, []},
            {"/online_info.php/[...]", online_info, []},
            {"/write_link_log/[...]", write_link_log, []},
            {"/get_back_rate/[...]", get_back_rate, []},
            {"/recharge_notify_4_all", recharge_notify_4_all, []},
            {"/query_4_all", query_4_all, []}
           ]
     }
    ].

reload_cowboy_routes() ->
    Routes = get_cowboy_routes(),
	Dispatch = cowboy_router:compile(Routes),
    cowboy:set_env(http, dispatch, Dispatch).

