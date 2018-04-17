-module(send_mail).

-include("log.hrl").
-include("account.hrl").
-include("guild.hrl").
-include("mail.hrl").
-include("sys_macro.hrl").
-include("system.hrl").
-include("log_type.hrl").

-export([handle/1]).

-record(send_mail, {
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
					mail_title     = <<>>,
					mail_content   = <<>>,
					min_vip_level  = 0,
					max_vip_level  = 2147483647,
					is_recharge    = 0,
					min_recharge_money = 0,
					max_recharge_money = 2147483647,
					min_recharge_time = 0,
					max_recharge_time = 2147483647,
					start_time     = 0,
					end_time       = 2147483647,
					orderid        = <<>>,
					sys_mail_id    = 0
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
			1000;
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
			util:unixtime() + ?SECONDS_PER_DAY;
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
			util:unixtime() + ?SECONDS_PER_DAY;
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

	NowTime = util:unixtime(),
	StartTime = 
	case lists:keyfind(<<"fetch_valid_start_time">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma fetch_valid_start_time missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, StartTime0} ->
			util:min(NowTime, util_background:bitstring_to_integer(StartTime0))
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

	Sql = io_lib:format("SELECT COUNT(1) FROM log_order WHERE order_id='~s'", [binary_to_list(OrderIDStr)]),
	?DBG(background, "Sql = ~s", [Sql]),
	case emysql:execute(oceanus_log_pool, Sql) of
		{result_packet,_,_,[[Data]],_} when Data > 0 ->
			?ERR(?MODULE, "parma order_id repeat"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{result_packet,_,_,[[Data]],_} when Data =< 0 ->
			InsertSql = io_lib:format("INSERT INTO log_order VALUES ('~s', 0)", [binary_to_list(OrderIDStr)]),
			emysql:execute(oceanus_log_pool, InsertSql),

			case ActionStr of
				<<"0">> ->
					SysMail = #sys_mail{
										sys_mail_id = g_uid:get(sys_mail),
										% order_id = OrderIDStr,
										mail_title = MailTitleStr,
										mail_content = MailContentStr,
										mail_send_time = StartTime,
										mail_invalid_time = EndTime
										},
					cache:insert(SysMail),

					OIDList = ets:tab2list(ets_online),
					IDList = [OID || {OID, _} <- OIDList],
					SendMail = #send_mail{
									mail_title     = MailTitleStr,
									mail_content   = MailContentStr,
									orderid        = OrderIDStr,
									sys_mail_id    = SysMail#sys_mail.sys_mail_id
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
					SendMail = #send_mail{
									mail_title     = MailTitleStr,
									mail_content   = MailContentStr,
									orderid        = OrderIDStr
								 };
				<<"2">> ->
					GuildID =
					case mod_guild:get_guild_by_name(GuildName) of
						[] ->
							0;
						[Guild] ->
							Guild#guild.id
					end,
					IDList = [ID || {_, ID} <- ets:tab2list(ets_nickname_id_map)],

					SysMailID = g_uid:get(sys_mail),

					SysMail = #sys_mail{
										sys_mail_id    = SysMailID,
										% order_id       = OrderIDStr,
										mail_title     = MailTitleStr,
										mail_content   = MailContentStr,
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

					SendMail = #send_mail{
											mail_title     = MailTitleStr,
											mail_content   = MailContentStr,
											orderid        = OrderIDStr,
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
											is_recharge    = IsRecharge,
											min_recharge_time = MinRechargeTime,
											max_recharge_time = MaxRechargeTime,
											min_recharge_money = MinRechargeMoney,
											max_recharge_money = MaxRechargeMoney,
											start_time     = StartTime,
											end_time       = EndTime,
											sys_mail_id    = SysMailID
										}
			end,

			do_send_mail(IDList, SendMail),

			UpdSql = io_lib:format("UPDATE log_order SET state=1 WHERE order_id='~s'", [binary_to_list(OrderIDStr)]),
			emysql:execute(oceanus_log_pool, UpdSql),

			{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")}]};
		_ ->
			{struct, [{code, <<"9001">>},{message, unicode:characters_to_binary("系统错误")}]}
	end.

do_send_mail([AccountID|Rest], SendMail) ->
	AccountRec1 = mod_account:lookup_account(AccountID),
	case SendMail#send_mail.sys_mail_id > 0 of
		true ->
			AccountRec = AccountRec1#account{ sys_mail_id=SendMail#send_mail.sys_mail_id };
		false ->
			AccountRec = AccountRec1
	end,

	VipLevel = mod_vip:get_vip_level(AccountID),
	GuildID =
	case cache:lookup(guild, AccountID) of
		[] ->
			0;
		[#guild_member{ guild_id=GID }] ->
			GID
	end,

	RechargeMoney =
	case SendMail#send_mail.is_recharge of
		0 ->
			0;
		_ ->
			g_recharge:get_time_recharge_money(AccountID, SendMail#send_mail.min_recharge_time, SendMail#send_mail.max_recharge_time)
	end,

	case AccountRec#account.level >= SendMail#send_mail.min_lv andalso AccountRec#account.level =< SendMail#send_mail.max_lv 
	  andalso AccountRec#account.last_login_time >= SendMail#send_mail.min_login_time 
	  andalso AccountRec#account.last_login_time =< SendMail#send_mail.max_login_time
	  andalso AccountRec#account.register_time >= SendMail#send_mail.min_reg_time
	  andalso AccountRec#account.register_time =< SendMail#send_mail.max_reg_time
	  % andalso (SendMail#send_mail.career == 0 orelse AccountRec#account.career == SendMail#send_mail.career)
	  andalso (SendMail#send_mail.sex == 0 orelse AccountRec#account.sex == SendMail#send_mail.sex)
	  andalso (SendMail#send_mail.platform_id == 0 orelse AccountRec#account.platform_id == SendMail#send_mail.platform_id)
	  andalso VipLevel >= SendMail#send_mail.min_vip_level 
	  andalso VipLevel =< SendMail#send_mail.max_vip_level
	  andalso (SendMail#send_mail.guild_id == 0 orelse GuildID == SendMail#send_mail.guild_id)
	  andalso (SendMail#send_mail.is_recharge == 0 orelse (RechargeMoney >= SendMail#send_mail.min_recharge_money andalso RechargeMoney =< SendMail#send_mail.max_recharge_money)) of
		false ->
			skip;
		true ->
			Mail = #mail{
							key = {AccountID, g_uid:get(mail)},						%% key
							mail_type = 1,											%% 邮件类型(1-战报类 2-公告类)
							mail_status = 0,										%% 邮件状态(0-未读 1-已读 2-删除)
							mail_sender_id = 0,										%% 发送者ID(0表示GM)
							mail_sender_nick_name = <<"GM">>,						%% 发送者名字
							mail_receiver_nick_name = AccountRec#account.nick_name,	%% 接收者名字
							mail_title = SendMail#send_mail.mail_title,				%% 邮件标题
							mail_content = SendMail#send_mail.mail_content,			%% 邮件内容
							mail_send_time = util:unixtime(),						%% 发送时间
							from_type = ?FROM_SYSTEM							%% 来源
							},
				mod_mail:add_mail_4_server(Mail)
	end,
	do_send_mail(Rest, SendMail);
do_send_mail([], _) ->
	ok.