%% 获取帮派信息
-module(guild_info_list).

-include("log.hrl").

-export([handle/1]).

handle(ArgList) ->
	Desc = {struct, [
					 {guild_id, unicode:characters_to_binary("帮派ID")},
					 {guild_name, unicode:characters_to_binary("帮派名称")},
					 {guild_level, unicode:characters_to_binary("帮派等级")},
					 {guild_ranking, unicode:characters_to_binary("帮派排名")},
					 {leader, unicode:characters_to_binary("帮派创建者")}
					]},

	{GuildIDStr, GuildIDCond} = 
	case lists:keyfind(<<"guild_id">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma guild_id missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{data, <<>>},{desc, Desc}]}});
		{_, <<>>} ->
			{[], ""};
		{_, GuildID0} ->
			{GuildID0, " AND a.guild_id =?"}
	end,

	{GuildNameStr,GuildNameCond} = 
	case lists:keyfind(<<"guild_name">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma guild_name missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{data, <<>>},{desc, Desc}]}});
		{_, <<>>} ->
			{[], ""};
		{_, GuildName0} ->
			{list_to_binary("%" ++ binary_to_list(GuildName0) ++ "%"), " AND a.name LIKE ?"}
	end,

	case util_background:check_tick(ArgList) of
		false ->
			?ERR(?MODULE, "check flag error"),
			throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")},{data, <<>>},{desc, Desc}]}});
		true ->
			ok
	end,

	Sql = io_lib:format("SELECT a.id,a.name,0,100,b.nick_name FROM gd_guild a,gd_account b WHERE b.id=a.creator~s~s",
		[GuildIDCond, GuildNameCond]),
	?DBG(?MODULE, "Sql=~s", [Sql]),

	case emysql:execute(oceanus_pool, Sql, lists:flatten([GuildIDStr, GuildNameStr])) of
		{result_packet,_,_,Result,_} ->
			Data = paseResult(Result, []),
			{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")},{data, Data},{desc, Desc}]};
		_ ->
			{struct, [{code, <<"9001">>},{message, unicode:characters_to_binary("系统错误")},{total_number, 0},{data, <<>>},{desc, Desc}]}
	end.

	

paseResult([], []) ->
	<<>>;
paseResult([[GuildID,GuildName,GuildLevel,GuildRank,GuildCreater]|Rest], ResultList) ->
	Result = {struct, [
					   {guild_id, GuildID},{guild_name, GuildName},{guild_level, GuildLevel},
					   {guild_ranking, GuildRank},{leader, GuildCreater}
					  ]},
	paseResult(Rest, [Result | ResultList]);
paseResult([], ResultList) ->
	ResultList.