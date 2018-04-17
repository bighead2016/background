-module(send_sys_bulletin).

-include("log.hrl").

-export([handle/1]).

%% http://192.168.1.235:10010/background/send_sys_bulletin?msg_type=1&content=恭喜玩家<text='勿忘我';color=0x22ff22>在招募中获得了<text='梦见水滴碎片';color=0x22ff22>，运气停不下来&send_times=10&inter_time=20

handle(ArgList) ->
	Operation =
	case lists:keyfind(<<"operation">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma operation missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			1;
		{_, Operation0} ->
			util_background:bitstring_to_integer(Operation0)
	end,

	NoticeID =
	case lists:keyfind(<<"noticeId">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma noticeId missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			1;
		{_, NoticeID0} ->
			util_background:bitstring_to_integer(NoticeID0)
	end,
	

	MsgType = 
	case lists:keyfind(<<"msg_type">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma msg_type missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			1;
		{_, MsgType0} ->
			util_background:bitstring_to_integer(MsgType0)
	end,

	Content = 
	case lists:keyfind(<<"content">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma content missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			?ERR(?MODULE, "parma content empty"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, Content0} ->
			Content0
	end,

	SendTimes =
	case lists:keyfind(<<"send_times">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma send_times missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			1;
		{_, SendTimes0} ->
			util_background:bitstring_to_integer(SendTimes0)
	end,

	InterTime =
	case lists:keyfind(<<"inter_time">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma inter_time missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			10;
		{_, InterTime0} ->
			max(10, util_background:bitstring_to_integer(InterTime0))
	end,

	% case util_background:check_tick(ArgList) of
	% 	false ->
	% 		?ERR(?MODULE, "check flag error"),
	% 		throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")}]}});
	% 	true ->
	% 		ok
	% end,

	g_bulletin:add_bulletin(Operation, NoticeID, MsgType, Content, 0, SendTimes, InterTime),

	{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")}]}.