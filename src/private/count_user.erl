-module(count_user).

-include("log.hrl").
-include("account.hrl").
-include("guild.hrl").
-include("mail.hrl").
-include("sys_macro.hrl").

-export([handle/1]).

-record(count_user, {
					min_lv         = 0,
					max_lv         = 2147483647,
					min_login_time = 0,
					max_login_time = 2147483647,
					min_reg_time   = 0,
					max_reg_time   = 2147483647,
					sex            = 0,
					career         = 0,
					guild_id       = 0,
					platform_id    = 0,
					min_vip_level  = 0,
					max_vip_level  = 2147483647,
					is_recharge    = 0,
					min_recharge_money = 0,
					max_recharge_money = 2147483647,
					min_recharge_time = 0,
					max_recharge_time = 2147483647
					}).

handle(ArgList) ->
	ActionStr = 
	case lists:keyfind(<<"action">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma action missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, Action0} ->
			Action0
	end,

	NameListStr = 
	case lists:keyfind(<<"user_names">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma user_names missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, NameList0} ->
			NameList0
	end,

	IDListStr = 
	case lists:keyfind(<<"user_ids">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma user_ids missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, IDList0} ->
			IDList0
	end,

	MinLv = 
	case lists:keyfind(<<"min_lv">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma min_lv missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, MinLv0} ->
			util_background:bitstring_to_integer(MinLv0)
	end,

	MaxLv = 
	case lists:keyfind(<<"max_lv">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma max_lv missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			2147483647;
		{_, MaxLv0} ->
			util_background:bitstring_to_integer(MaxLv0)
	end,

	MinLoginTime = 
	case lists:keyfind(<<"min_login_time">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma min_login_time missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, MinLogin0} ->
			util_background:bitstring_to_integer(MinLogin0)
	end,

	MaxLoginTime = 
	case lists:keyfind(<<"max_login_time">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma max_login_time missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			2147483647;
		{_, MaxLogin0} ->
			util_background:bitstring_to_integer(MaxLogin0)
	end,

	MinRegTime = 
	case lists:keyfind(<<"min_reg_time">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma min_reg_time missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, MinReg0} ->
			util_background:bitstring_to_integer(MinReg0)
	end,

	MaxRegTime = 
	case lists:keyfind(<<"max_reg_time">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma max_reg_time missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			2147483647;
		{_, MaxReg0} ->
			util_background:bitstring_to_integer(MaxReg0)
	end,

	Sex = 
	case lists:keyfind(<<"sex">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma sex missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, Sex0} ->
			util_background:bitstring_to_integer(Sex0)
	end,

	Career = 
	case lists:keyfind(<<"career">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma career missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, Career0} ->
			util_background:bitstring_to_integer(Career0)
	end,

	GuildName = 
	case lists:keyfind(<<"guild">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma guild missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, Guild0} ->
			Guild0
	end,

	MinVipLevel = 
	case lists:keyfind(<<"min_vip_level">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma min_vip_level missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, MinVipLevel0} ->
			util_background:bitstring_to_integer(MinVipLevel0)
	end,

	MaxVipLevel = 
	case lists:keyfind(<<"max_vip_level">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma max_vip_level missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			2147483647;
		{_, MaxVipLevel0} ->
			util_background:bitstring_to_integer(MaxVipLevel0)
	end,

	IsRecharge =
	case lists:keyfind(<<"is_recharge">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma is_recharge missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, IsRecharge0} ->
			util_background:bitstring_to_integer(IsRecharge0)
	end,

	MinRechargeMoney = 
	case lists:keyfind(<<"min_recharge_money">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma min_recharge_money missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, MinRechargeMoney0} ->
			util_background:bitstring_to_integer(MinRechargeMoney0)
	end,

	MaxRechargeMoney = 
	case lists:keyfind(<<"max_recharge_money">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma max_recharge_money missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->	
			2147483647;
		{_, MaxRechargeMoney0} ->
			util_background:bitstring_to_integer(MaxRechargeMoney0)
	end,

	MinRechargeTime = 
	case lists:keyfind(<<"min_recharge_time">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma min_recharge_time missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, MinRechargeTime0} ->
			util_background:bitstring_to_integer(MinRechargeTime0)
	end,

	MaxRechargeTime = 
	case lists:keyfind(<<"max_recharge_time">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma max_recharge_time missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->	
			2147483647;
		{_, MaxRechargeTime0} ->
			util_background:bitstring_to_integer(MaxRechargeTime0)
	end,

	PlatformID = 
	case lists:keyfind(<<"platform_id">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma platform_id missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, PlatformID0} ->
			util_background:bitstring_to_integer(PlatformID0)
	end,

	case util_background:check_tick(ArgList) of
		false ->
			?ERR(?MODULE, "check flag error"),
			throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")}]}});
		true ->
			ok
	end,


	case ActionStr of
		<<"1">> ->
			IDList1 = util_background:get_integer_list(IDListStr),
			NameList = util_background:get_string_list(NameListStr),
			Sum =
			if
				IDList1 == [] andalso NameList == [] ->
					0;
				NameList == [] ->
					F = fun(ID, Sum) ->
						case cache:lookup(account, ID) of
							[] ->
								Sum;
							[_] ->
								Sum + 1
						end
					end,
					lists:foldl(F, 0, IDList1);
				true ->
					F1 = fun(NickName, Sum) ->
						case cache:lookup(ets_nickname_id_map, NickName) of
							[] ->
								Sum;
							[_] ->
								Sum + 1
						end
					end,
					lists:foldl(F1, 0, NameList)
			end;
		_ ->
			GuildID =
			case mod_guild:get_guild_by_name(GuildName) of
				[] ->
					0;
				[Guild] ->
					Guild#guild.id
			end,

			IDList = ets:tab2list(ets_nickname_id_map),				

			CountUser = #count_user{
									min_lv         = MinLv,
									max_lv         = MaxLv,
									min_login_time = MinLoginTime,
									max_login_time = MaxLoginTime,
									min_reg_time   = MinRegTime,
									max_reg_time   = MaxRegTime,
									sex            = Sex,
									career         = Career,
									guild_id       = GuildID,
									platform_id    = PlatformID,
									min_vip_level  = MinVipLevel,
									max_vip_level  = MaxVipLevel,
									is_recharge    = IsRecharge,
									min_recharge_money = MinRechargeMoney,
									max_recharge_money = MaxRechargeMoney,
									min_recharge_time = MinRechargeTime,
									max_recharge_time = MaxRechargeTime
								 },

			?DBG(count_user, "CountUser = ~p : ~p", [CountUser, length(IDList)]),

			Sum = do_count_user(IDList, CountUser, 0)
	end,
	{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")},{total_number,Sum}]}.

do_count_user([{_, AccountID}|Rest], CountUser, Sum) ->
	AccountRec = mod_account:lookup_account(AccountID),

	VipLevel = mod_vip:get_vip_level(AccountID),
	GuildID =
	case cache:lookup(guild, AccountID) of
		[] ->
			0;
		[#guild_member{ guild_id=GID }] ->
			GID
	end,

	RechargeMoney =
	case CountUser#count_user.is_recharge of
		0 ->
			0;
		_ ->
			g_recharge:get_time_recharge_money(AccountID, CountUser#count_user.min_recharge_time, CountUser#count_user.max_recharge_time)
	end,

	NewSum =
	case AccountRec#account.level >= CountUser#count_user.min_lv andalso AccountRec#account.level =< CountUser#count_user.max_lv 
	  andalso AccountRec#account.last_login_time >= CountUser#count_user.min_login_time 
	  andalso AccountRec#account.last_login_time =< CountUser#count_user.max_login_time
	  andalso AccountRec#account.register_time >= CountUser#count_user.min_reg_time
	  andalso AccountRec#account.register_time =< CountUser#count_user.max_reg_time
	  % andalso (CountUser#count_user.career == 0 orelse AccountRec#account.career == CountUser#count_user.career)
	  andalso (CountUser#count_user.sex == 0 orelse AccountRec#account.sex == CountUser#count_user.sex) 
	  andalso (CountUser#count_user.platform_id == 0 orelse AccountRec#account.platform_id == CountUser#count_user.platform_id)
	  andalso VipLevel >= CountUser#count_user.min_vip_level 
	  andalso VipLevel =< CountUser#count_user.max_vip_level
	  andalso (CountUser#count_user.guild_id == 0 orelse GuildID == CountUser#count_user.guild_id)
	  andalso (CountUser#count_user.is_recharge == 0 orelse (RechargeMoney >= CountUser#count_user.min_recharge_money andalso RechargeMoney =< CountUser#count_user.max_recharge_money)) of
		false ->
			Sum;
		true ->
			Sum + 1
	end,
	do_count_user(Rest, CountUser, NewSum);
do_count_user([], _, Sum) ->
	Sum.