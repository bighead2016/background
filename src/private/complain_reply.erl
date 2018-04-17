-module(complain_reply).

-include("log.hrl").
-include("account.hrl").
-include("sys_macro.hrl").
-include("mail.hrl").
-include("log_type.hrl").

-export([handle/1]).

handle(ArgList) ->
	NameStr = 
	case lists:keyfind(<<"user_name">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma user_name missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, Name0} ->
			Name0
	end,

	ContentStr = 
	case lists:keyfind(<<"content">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma user_name missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")}]}});
		{_, Content0} ->
			Content0
	end,

	case util_background:check_tick(ArgList) of
		false ->
			?ERR(?MODULE, "check flag error"),
			throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")}]}});
		true ->
			ok
	end,

	case ets:lookup(ets_nickname_id_map, NameStr) of
		[] ->
			skip;
		[{_, AccountID}] ->
			Mail = #mail{
						key = {AccountID, g_uid:get(mail)},
						mail_type = 1,										%% 邮件类型(1-战报类 2-公告类)
						mail_status = 0,										%% 邮件状态(0-未读 1-已读 2-删除)
						mail_sender_id = 0,										%% 发送者ID(0表示GM)
						mail_sender_nick_name = <<"GM">>,								%% 发送者名字
						mail_receiver_nick_name = NameStr,								%% 接收者名字
						mail_title = <<"BUG/建议回复">>,					%% 邮件标题
						mail_content = ContentStr,								%% 邮件内容
						mail_send_time = util:unixtime(),						%% 发送时间
						from_type = ?FROM_SYSTEM										%% 来源
						},
			mod_mail:add_mail(Mail)
	end,
	{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")}]}.