-module(search_gift_state).

-include("log.hrl").
-include("system.hrl").

-export([handle/1]).

handle(ArgList) ->
	OrderIDStr = 
	case lists:keyfind(<<"orderid">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma orderid missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			?ERR(?MODULE, "parma orderid empty"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, OrderIDStr0} ->
			util_background:get_string_list(OrderIDStr0)
	end,

	case util_background:check_tick(ArgList) of
		false ->
			?ERR(?MODULE, "check flag error"),
			throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")}]}});
		true ->
			ok
	end,

	

	Sql = io_lib:format("SELECT state FROM log_order WHERE order_id='~s'", [binary_to_list(OrderIDStr)]),
	Data = 
	case emysql:execute(oceanus_log_pool, Sql) of
		{result_packet,_,_,[[Count]],_} when Count =< 0 ->
			{struct, [{state, <<"process">>}, {fail_role, <<>>}]};
		{result_packet,_,_,[[Count]],_} when Count > 0 ->
			{struct, [{state, <<"success">>}, {fail_role, <<>>}]};
		_ ->
			{struct, [{state, <<"failed">>}, {fail_role, <<>>}]}
	end,

	{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")},{data, Data}]}.