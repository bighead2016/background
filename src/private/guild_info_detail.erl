-module(guild_info_detail).

-include("log.hrl").
-include("account.hrl").
-include("economy.hrl").
-include("guild.hrl").
-include("rank.hrl").
-include("sys_macro.hrl").

-export([
		handle/1
		]).

handle(ArgList) ->
	Desc = {struct, [
					 {guild_id, unicode:characters_to_binary("帮派ID")},
					 {guild_name, unicode:characters_to_binary("帮派名称")},
					 {guild_level, unicode:characters_to_binary("帮派等级")},
					 {guild_ranking, unicode:characters_to_binary("帮派排名")},
					 {leader, unicode:characters_to_binary("帮派创建者")},
					 % {create_time, unicode:characters_to_binary("创建时间")},
					 {member_count, unicode:characters_to_binary("帮派人数")},
					 {member_list, unicode:characters_to_binary("玩家列表")}
					]},

	GuildName = 
	case lists:keyfind(<<"guild_name">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma guild_name missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{data, <<>>},{desc, Desc}]}});
		{_, GuildName0} ->
			GuildName0
	end,

	GuildID = 
	case lists:keyfind(<<"guild_id">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma guild_id missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{data, <<>>},{desc, Desc}]}});
		{_, <<>>} ->
			case GuildName of
				<<>> ->
					-1;
				_ ->
					case mod_guild:get_guild_by_name(GuildName) of
						[] ->
							-1;
						[#guild{ id=GID }] ->
							GID
					end
			end;
		{_, GuildID0} ->
			util_background:bitstring_to_integer(GuildID0)
	end,

	case util_background:check_tick(ArgList) of
		false ->
			?ERR(?MODULE, "check flag error"),
			throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")},{data, <<>>},{desc, Desc}]}});
		true ->
			ok
	end,

	Data =
	case cache:lookup(guild, GuildID) of
		[] ->
			<<>>;
		[GuildInfo] ->
			MemberNameList = get_guild_member_name_list(GuildInfo#guild.members),
			LeaderInfo = util_background:get_account_info_by_id(GuildInfo#guild.creator),
			GuildRank = 0, %mod_rank:get_my_rank(?RANK_TYPE_GUILD,GuildID),
			% CreateTime = list_to_binary(util:unixtime_to_timestamp(GuildInfo#guild.creat_time)),
			{struct, [
						{guild_id, GuildID},
						{guild_name, GuildInfo#guild.name},
						{guild_level, 0},
						{guild_ranking, GuildRank},
						{leader, LeaderInfo#account.nick_name},
						% {create_time, CreateTime},
						{member_count, length(MemberNameList)},
						{member_list, MemberNameList}
					]}
	end,
	{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")},{data, Data},{desc, Desc}]}.

get_guild_member_name_list([{AccountID, _}|Rest]) ->
	case util_background:get_account_info_by_id(AccountID) of
		none ->
			NickName = "";
		AccountInfo ->
			NickName = AccountInfo#account.nick_name
	end,
	RestNameList = get_guild_member_name_list(Rest),
	[NickName|RestNameList];
get_guild_member_name_list([]) ->
	[].