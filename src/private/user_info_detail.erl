%% 获取单个用户详细信息
-module(user_info_detail).

-include("log.hrl").
-include("account.hrl").
-include("economy.hrl").
-include("guild.hrl").
-include("counter.hrl").
-include("role.hrl").

-export([handle/1]).
-compile(export_all).

handle(ArgList) ->
	Desc1 = [
				 {account, unicode:characters_to_binary("玩家平台账号")},
				 {user_id, unicode:characters_to_binary("玩家ID")},
				 {user_name, unicode:characters_to_binary("玩家角色名")},
				 {reg_time, unicode:characters_to_binary("角色创建时间")},
				 {level, unicode:characters_to_binary("玩家等级")},
				 % {last_login_ip, unicode:characters_to_binary("玩家最后登录IP")},
				 {last_login_time, unicode:characters_to_binary("玩家最后登录时间")},
				 {cuntry, unicode:characters_to_binary("玩家阵营名称")},
				 {guild, unicode:characters_to_binary("玩家帮派名称")},
				 {career, unicode:characters_to_binary("玩家职业名称")},
				 {is_online, unicode:characters_to_binary("是否在线")},
				 {is_forbid, unicode:characters_to_binary("是否封号")},
				 {vip_level, unicode:characters_to_binary("VIP等级")},
				 {vip_limit_time, unicode:characters_to_binary("VIP到期时间")},
				 {charge_money, unicode:characters_to_binary("充值总额")},
				 {gold, unicode:characters_to_binary("金币")},
				 {diamond, unicode:characters_to_binary("钻石")},
				 {wood, unicode:characters_to_binary("木材")},
				 {mine, unicode:characters_to_binary("矿石")}
			],

	AccountStr = 
	case lists:keyfind(<<"account">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma account missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{desc, {struct,Desc1}},{data, <<>>}]}});
		{_, Account0} ->
			 Account0
	end,

	NameStr = 
	case lists:keyfind(<<"user_name">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma user_name missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{desc, {struct,Desc1}},{data, <<>>}]}});
		{_, Name0} ->
			Name0
	end,

	AccountRec = 
	case lists:keyfind(<<"user_id">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma user_id missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{desc, {struct,Desc1}},{data, <<>>}]}});
		{_, <<>>} ->
			case ets:lookup(ets_name_id_map, NameStr) of
				[] ->
					none;
				[{_, AccountID}] ->
					util_background:get_account_info_by_id(AccountID)
			end;
		{_, MsgType0} ->
			 AccountID = util_background:bitstring_to_integer(MsgType0),
			 util_background:get_account_info_by_id(AccountID)
	end,

	case util_background:check_tick(ArgList) of
		false ->
			?ERR(?MODULE, "check flag error"),
			throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")},{desc, {struct,Desc1}},{data, <<>>}]}});
		true ->
			ok
	end,

	{Desc, Data} =
	case AccountRec of
		none ->
			{{struct, Desc1}, <<>>};
		_ ->
			IsOnline =
			case ets:lookup(ets_online, AccountRec#account.id) of
				[_] ->
					unicode:characters_to_binary("是");
				_ ->
					unicode:characters_to_binary("否")
			end,

			IsForbid =
			case AccountRec#account.is_lock of
				0 ->
					unicode:characters_to_binary("否");
				_ ->
					unicode:characters_to_binary("是")
			end,

			case cache:lookup(AccountRec#account.id) of
				[GuildMember] when GuildMember#guild_member.guild_id > 0 ->
					[GuildInfo] = cache:lookup(guild, GuildMember#guild_member.guild_id),
					GuildName = GuildInfo#guild.name;
				_ ->
					GuildName = <<>>
			end,

			Economy = mod_economy:get_economy(AccountRec#account.id),

			PlatformName = util_oceanus:get_platform_name(AccountRec#account.platform_id),

			OnBattleRoles1 = mod_role:get_on_battle_roles(AccountRec#account.id),

			OnBattleRoles = lists:sort(fun(A, B) -> A#role.pos < B#role.pos end, OnBattleRoles1),

			{ElementList, Desc2} = fill_roles_list(OnBattleRoles, 1),

			VipLevel = mod_vip:get_vip_level(AccountRec#account.id),

			{{struct, Desc1++Desc2},

			{struct, [
							 {account, AccountRec#account.account},
							 {user_id, AccountRec#account.id},
							 {user_name, AccountRec#account.nick_name},
							 {reg_time, list_to_binary(util:unixtime_to_timestamp(AccountRec#account.register_time))},
							 {level, AccountRec#account.level},
							 % {last_login_ip, AccountRec#account.ip},
							 {last_login_time, list_to_binary(util:unixtime_to_timestamp(AccountRec#account.last_login_time))},
							 {cuntry, PlatformName},
							 {guild, GuildName},
							 {career, -1},
							 {is_online, IsOnline},
							 {is_forbid, IsForbid},
							 {vip_level, VipLevel},
							 {vip_limit_time, <<"1970-01-01 00:00:00">>},
							 {charge_money, mod_per_counter:get(AccountRec#account.id, ?COUNTER_TYPE_RECHARGE_MONEY)},
							 {gold, Economy#economy.gold},
							 {diamond, Economy#economy.diamond},
							 {wood, Economy#economy.wood}
							] ++ ElementList}}
	end,
	{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")},{data, Data},{desc, Desc}]}.

fill_roles_list([Role|Rest], Num) ->
	Color = get_role_color(Role#role.star),
	#role_cfg{ name=Name } = data_role:get(Role#role.cfg_id),
	RoleInfo = unicode:characters_to_binary(Name ++ "  " ++ integer_to_list(Role#role.lv) ++ "  " ++ Color),
	Tag = list_to_atom(atom_to_list(role_info) ++ integer_to_list(Num)),
	Element = [{Tag, RoleInfo}],
	DescTag = unicode:characters_to_binary("英灵" ++ integer_to_list(Num)),
	Desc = [{Tag,DescTag}],
	{RestElement, RestDesc} = fill_roles_list(Rest, Num + 1),
	{Element ++ RestElement, Desc ++ RestDesc};
fill_roles_list([], _) ->
	{[], []}.

get_role_color(1) -> "白";
get_role_color(2) -> "绿";
get_role_color(3) -> "蓝";
get_role_color(4) -> "紫";
get_role_color(5) -> "橙";
get_role_color(6) -> "红";
get_role_color(Star) -> integer_to_list(Star).