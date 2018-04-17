-module(admin_send_gift).

-include("log.hrl").
-include("account.hrl").
-include("guild.hrl").
-include("mail.hrl").
-include("sys_macro.hrl").
-include("system.hrl").
-include("log_type.hrl").
-include("counter.hrl").
-include("background.hrl").
-include("award.hrl").

-record(send_gift, {
					mail_title     = <<>>,
					mail_content   = <<>>,
					recharge_diamond = 0,
					item_list      = [],
					orderid        = <<>>,
					sex            = 0,
					career         = 0,
					guild_id	   = 0,
					platform_id    = 0,
					min_lv         = 0,
					max_lv         = 2147483647,
					min_login_time = 0,
					max_login_time = 2147483647,
					min_reg_time   = 0,
					max_reg_time   = 2147483647,
					min_vip_level  = 0,
					max_vip_level  = 2147483647,
					is_recharge    = 0,
					min_recharge_money = 0,
					max_recharge_money = 2147483647,
					min_recharge_time = 0,
					max_recharge_time = 2147483647,
					start_time     = 0,
					end_time       = 2147483647,
					sys_mail_id    = 0
					}).

-export([handle/1]).

-compile(export_all).

%% http://192.168.1.235:10010/background/admin_send_gift?action=2&user_names=&user_ids=&min_lv=1&max_lv=100&min_login_time=&max_login_time=&min_reg_time=&max_reg_time=&sex=&career=&guild=&mail_title=this is a test mail&mail_content=content test test&min_vip_level=&max_vip_level=&orderid=123&money_amounts=100,200&money_types=1,2&item_ids=1001,1002&item_types=1,1&item_counts=1,1&fetch_valid_start_time=&fetch_valid_end_time=&is_recharge=&min_recharge_money=&max_recharge_money=&min_recharge_time=&max_recharge_time=&platform_id=&flag=cb5b06828350db28ae71c5e2289c09b3

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

	MailTitleStr = 
	case lists:keyfind(<<"mail_title">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma mail_title missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, MailTitle0} ->
			MailTitle0
	end,


	MailContentStr = 
	case lists:keyfind(<<"mail_content">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma mail_content missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, MailContent0} ->
			MailContent0
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

	OrderIDStr = 
	case lists:keyfind(<<"orderid">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma orderid missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->
			?ERR(?MODULE, "parma orderid missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, OrderID0} ->
			OrderID0
	end,

	MoneyAmountsStr = 
	case lists:keyfind(<<"money_amounts">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma money_amounts missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, MoneyAmounts0} ->
			MoneyAmounts0
	end,

	MoneyTypesStr = 
	case lists:keyfind(<<"money_types">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma money_types missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, MoneyTypes0} ->
			MoneyTypes0
	end,

	ItemIDsStr = 
	case lists:keyfind(<<"item_ids">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma item_ids missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, ItemIDs0} ->
			ItemIDs0
	end,

	ItemTypesStr = 
	case lists:keyfind(<<"item_types">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma item_types missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, ItemTypes0} ->
			ItemTypes0
	end,

	ItemCountsStr = 
	case lists:keyfind(<<"item_counts">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma item_counts missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, ItemCounts0} ->
			ItemCounts0
	end,

	NowTime = util:unixtime(),
	StartTime = 
	case lists:keyfind(<<"fetch_valid_start_time">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma fetch_valid_start_time missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, StartTime0} ->
			util:max(NowTime, util_background:bitstring_to_integer(StartTime0))
	end,

	EndTime = 
	case lists:keyfind(<<"fetch_valid_end_time">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma fetch_valid_end_time missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, <<>>} ->	
			2147483647;
		{_, EndTime0} ->
			util:max(NowTime, util_background:bitstring_to_integer(EndTime0))
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

	% case util_background:check_tick(ArgList) of
	% 	false ->
	% 		?ERR(?MODULE, "check flag error"),
	% 		throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")}]}});
	% 	true ->
	% 		ok
	% end,


	Sql = io_lib:format("SELECT COUNT(1) FROM log_order WHERE order_id='~s'", [binary_to_list(OrderIDStr)]),
	?DBG(background, "Sql = ~s", [Sql]),
	% case emysql:execute(mgserver_log_pool, Sql) of
	% 	{result_packet,_,_,[[Data]],_} when Data > 0 ->
	% 		?ERR(?MODULE, "parma order_id repeat"),
	% 		throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
	% 	{result_packet,_,_,[[Data]],_} when Data =< 0 ->

	% 		InsertSql = io_lib:format("INSERT INTO log_order VALUES ('~s', 0)", [binary_to_list(OrderIDStr)]),
	% 		emysql:execute(mgserver_log_pool, InsertSql),

			{ItemList, RechargeDiamond} = 
			get_send_gift(MoneyAmountsStr, MoneyTypesStr, ItemIDsStr, ItemTypesStr, ItemCountsStr),

			case ActionStr of
				<<"0">> ->
					SysMail = #sys_mail{
										sys_mail_id = g_uid:get(sys_mail),
										% order_id = OrderIDStr,
										mail_title = MailTitleStr,
										mail_content = MailContentStr,
										attachment_diamond = RechargeDiamond,
										attachment_items = ItemList,
										mail_send_time = StartTime,
										mail_invalid_time = EndTime
										},
					cache:insert(SysMail),
					OIDList = ets:tab2list(ets_online),
					IDList = [OID || {OID, _} <- OIDList],

					SendGift = #send_gift{
									mail_title       = MailTitleStr,
									mail_content     = MailContentStr,
									orderid          = OrderIDStr,
									recharge_diamond = RechargeDiamond,
									item_list        = ItemList,
									sys_mail_id      = SysMail#sys_mail.sys_mail_id
								 };
				<<"1">> ->
					IDList1 = util_background:get_integer_list(IDListStr),
					NameList = util_background:get_string_list(NameListStr),
					if
						IDList1 == [] andalso NameList == [] ->
							IDList = [];
						NameList == [] ->
							IDList = IDList1;
						true ->
							NameIDList = lists:flatten([ets:lookup(ets_nickname_id_map,N) || N <- NameList]),
							IDList = [ID || {_, ID} <- NameIDList]
					end,
					SendGift = #send_gift{
									mail_title        = MailTitleStr,
									mail_content      = MailContentStr,
									orderid           = OrderIDStr,
									recharge_diamond  = RechargeDiamond,
									item_list         = ItemList
								 };
				_ ->
					GuildID =
					case mod_guild:get_guild_by_name(GuildName) of
						[] ->
							0;
						Guild ->
							Guild#guild.id
					end,

					OIDList = ets:tab2list(ets_online),
					IDList = [OID || {OID, _} <- OIDList],

					SysMailID = g_uid:get(sys_mail),
					SysMail = #sys_mail{
										sys_mail_id = SysMailID,
										% order_id = OrderIDStr,
										mail_title = MailTitleStr,
										mail_content = MailContentStr,
										attachment_diamond = RechargeDiamond,
										attachment_items = ItemList,
										sex            = Sex,
										career         = Career,
										min_vip_level  = MinVipLevel,
										max_vip_level  = MaxVipLevel,
										guild_id       = GuildID,
										platform_id    = PlatformID,
										min_level      = MinLv,
										max_level      = MaxLv,
										min_login_time = MinLoginTime,
										max_login_time = MaxLoginTime,
										min_reg_time   = MinRegTime,
										max_reg_time   = MaxRegTime,
										is_recharge    = IsRecharge,
										min_recharge_time = MinRechargeTime,
										max_recharge_time = MaxRechargeTime,
										min_recharge_money = MinRechargeMoney,
										max_recharge_money = MaxRechargeMoney,
										mail_send_time = StartTime,
										mail_invalid_time = EndTime
										},
					cache:insert(SysMail),

					SendGift = #send_gift{
									mail_title     = MailTitleStr,
									mail_content   = MailContentStr,
									orderid        = OrderIDStr,
									item_list      = ItemList,
									career         = Career,
									sex            = Sex,
									guild_id       = GuildID,
									platform_id    = PlatformID,
									min_vip_level  = MinVipLevel,
									max_vip_level  = MaxVipLevel,
									min_lv         = MinLv,
									max_lv         = MaxLv,
									min_login_time = MinLoginTime,
									max_login_time = MaxLoginTime,
									min_reg_time   = MinRegTime,
									max_reg_time   = MaxRegTime,
									recharge_diamond = RechargeDiamond,
									is_recharge    = IsRecharge,
									min_recharge_money = MinRechargeMoney,
									max_recharge_money = MaxRechargeMoney,
									min_recharge_time = MinRechargeTime,
									max_recharge_time = MaxRechargeTime,
									start_time     = StartTime,
									end_time       = EndTime,
									sys_mail_id    = SysMailID
								 }
			end,
			do_send_gift(IDList, SendGift),
			% UpdSql = io_lib:format("UPDATE log_order SET state=~w WHERE order_id='~s'", [1, binary_to_list(OrderIDStr)]),
			% emysql:execute(oceanus_log_pool, UpdSql),

			{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")}]}.
	% 	_ ->
	% 		{struct, [{code, <<"9001">>},{message, unicode:characters_to_binary("系统错误")}]}
	% end.

do_send_gift([AccountID|Rest], SendGift) ->
	try
		AccountRec1 = mod_account:lookup_account(AccountID),
		case SendGift#send_gift.sys_mail_id > 0 of
			true ->
				AccountRec = AccountRec1#account{ sys_mail_id=SendGift#send_gift.sys_mail_id },
				cache:update(AccountRec);
			false ->
				AccountRec = AccountRec1
		end,
		VipLevel = mod_vip:get_vip_level(AccountID),
		GuildID =
		case cache:lookup(guild_member, AccountID) of
			[] ->
				0;
			[#guild_member{ guild_id=GID }] ->
				GID
		end,

		RechargeMoney =
		case SendGift#send_gift.is_recharge of
			0 ->
				0;
			_ ->
				g_recharge:get_time_recharge_money(AccountID, SendGift#send_gift.min_recharge_time, SendGift#send_gift.max_recharge_time)
		end,

		case AccountRec#account.level >= SendGift#send_gift.min_lv andalso AccountRec#account.level =< SendGift#send_gift.max_lv 
		  andalso AccountRec#account.last_login_time >= SendGift#send_gift.min_login_time 
		  andalso AccountRec#account.last_login_time =< SendGift#send_gift.max_login_time
		  andalso AccountRec#account.register_time >= SendGift#send_gift.min_reg_time
		  andalso AccountRec#account.register_time =< SendGift#send_gift.max_reg_time
		  % andalso (SendGift#send_gift.career == 0 orelse AccountRec#account.career == SendGift#send_gift.career)
		  andalso (SendGift#send_gift.sex == 0 orelse AccountRec#account.sex == SendGift#send_gift.sex) 
		  andalso (SendGift#send_gift.platform_id == 0 orelse AccountRec#account.platform_id == SendGift#send_gift.platform_id)
		  andalso VipLevel >= SendGift#send_gift.min_vip_level 
		  andalso VipLevel =< SendGift#send_gift.max_vip_level
		  andalso (SendGift#send_gift.guild_id == 0 orelse GuildID == SendGift#send_gift.guild_id)
		  andalso (SendGift#send_gift.is_recharge == 0 orelse (RechargeMoney >= SendGift#send_gift.min_recharge_money andalso RechargeMoney =< SendGift#send_gift.max_recharge_money)) of
			false ->
				skip;
			true ->
				SysAward = #award{ 
									item_list = SendGift#send_gift.item_list,
									recharge_diamond = SendGift#send_gift.recharge_diamond,
									title = SendGift#send_gift.mail_title,
									content = SendGift#send_gift.mail_content,
									award_time = util:unixtime(),
									from_type = ?FROM_SYSTEM
								},
				mod_award:mail_award(AccountID, SysAward)
		end
	catch ErrCode:ErrMsg ->
		?ERR(background, "ErrCode=~p, ErrMsg=~p", [ErrCode,ErrMsg]),
		ok
	end,
	do_send_gift(Rest, SendGift);
do_send_gift([], _) ->
	ok.

get_send_gift(MoneyAmountsStr, MoneyTypesStr, ItemIDsStr, ItemTypesStr, ItemCountsStr) ->
	MoneyAmountList = util_background:get_integer_list(MoneyAmountsStr),
	MoneyTypeList = util_background:get_integer_list(MoneyTypesStr),

	ItemIDList = util_background:get_integer_list(ItemIDsStr),
	ItemTypeList = util_background:get_integer_list(ItemTypesStr),
	ItemCountList = util_background:get_integer_list(ItemCountsStr),

	ItemList = get_item_gift(ItemIDList, ItemCountList),
	EconomyList = get_economy_gift(MoneyTypeList, MoneyAmountList),
	RechargeDiamond =
	case lists:keyfind(diamond, 1, EconomyList) of
		false ->
			0;
		{_, RCD} ->
			RCD
	end,

	NewItemList = item_util:economy_to_item(lists:keydelete(diamond, 1, EconomyList), ItemList),

	{NewItemList, RechargeDiamond}.

get_item_gift([ItemID|RestIDList], [ItemCount|RestCountList]) ->
	ItemTuple = {ItemID, ItemCount},
	RestList = get_item_gift(RestIDList, RestCountList),
	[ItemTuple|RestList];
get_item_gift([], _) ->
	[];
get_item_gift(_, []) ->
	[].

get_economy_gift([MoneyType|RestTypeList], [MoneyAmount|RestAmountList]) ->
	?ERR(?MODULE, "MoneyType = ~p, MoneyAmount=~p", [MoneyType, MoneyAmount]),
	MoneyTuple = 
	case MoneyType of
		1 ->
			[{diamond, MoneyAmount}];
		_ ->
			[]
	end,
	RestList = get_economy_gift(RestTypeList, RestAmountList),
	MoneyTuple ++ RestList;
get_economy_gift([], _) ->
	[];
get_economy_gift(_, []) ->
	[].


get_charge_money(MoneyAmountsStr, MoneyTypesStr) ->

	AmountList = util_background:get_integer_list(MoneyAmountsStr),
	TypeList = util_background:get_integer_list(MoneyTypesStr),

	NList =
	case length(TypeList) - length(AmountList) of
		0 ->
			lists:zip(TypeList, AmountList);
		Diff when Diff > 0 ->
			lists:zip(TypeList, AmountList ++ lists:duplicate(Diff, 0));
		Diff ->
			lists:zip(TypeList ++ lists:duplicate(-Diff, 0), AmountList)
	end,

	case lists:keyfind(4, 1, NList) of
		false ->
			no_set;
		{_, MinMoney} ->
			case lists:keyfind(5, 1, NList) of
				false ->
					no_set;
				{_, MaxMoney} ->
					case MaxMoney >= MinMoney andalso MaxMoney > 0 of
						true ->
							{MinMoney, MaxMoney};
						false ->
							no_set
					end
			end
	end.