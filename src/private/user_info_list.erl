%% 获取玩家列表
-module(user_info_list).

-include("log.hrl").

-export([
		handle/1
		]).
-compile(export_all).

handle(ArgList) ->
	Desc = {struct, [
					 {account, unicode:characters_to_binary("玩家平台账号")},
					 {user_id, unicode:characters_to_binary("玩家ID")},
					 {user_name, unicode:characters_to_binary("玩家角色名")},
					 {reg_time, unicode:characters_to_binary("角色创建时间")},
					 {level, unicode:characters_to_binary("玩家等级")},
					 {last_login_ip, unicode:characters_to_binary("玩家最后登录IP")},
					 {last_login_time, unicode:characters_to_binary("玩家最后登录时间")},
					 {cuntry, unicode:characters_to_binary("玩家阵营名称")}
					]},
	
	{NameStr, NameCond} = 
	case lists:keyfind(<<"user_name">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma user_name missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{total_number,0},{desc, Desc},{data, <<>>}]}});
		{_, <<>>} ->
			{[], ""};
		{_, Name0} ->
			{list_to_binary("%" ++ binary_to_list(Name0) ++ "%"), " AND nick_name LIKE ?"}
	end,

	{IDStr, IDCond} = 
	case lists:keyfind(<<"user_id">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma user_id missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{total_number,0},{desc, Desc},{data, <<>>}]}});
		{_, <<>>} ->
			{[], ""};
		{_, ID0} ->
			 {ID0, " AND ID = ?"}
	end,

	{AccountStr, AccountCond} = 
	case lists:keyfind(<<"account">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma account missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{total_number,0},{desc, Desc},{data, <<>>}]}});
		{_, <<>>} ->
			{[], ""};
		{_, Account0} ->
			 {Account0, " AND account=?"}
	end,

	IsOnlineCond = 
	case lists:keyfind(<<"is_online">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma is_online missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{total_number,0},{desc, Desc},{data, <<>>}]}});
		{<<"is_online">>, <<"1">>} ->
			get_online_cond();
		{<<"is_online">>, _} ->
			""
	end,

	{IPStr,LastLoginIPCond} = 
	case lists:keyfind(<<"last_login_ip">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma last_login_ip missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{total_number,0},{desc, Desc},{data, <<>>}]}});
		{_, <<>>} ->
			{[], ""};
		{_, LastLoginIP0} ->
			{LastLoginIP0, " AND login_ip = ?"}
	end,

	CurPage = 
	case lists:keyfind(<<"page_num">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma page_num missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{total_number,0},{desc, Desc},{data, <<>>}]}});
		{_, <<>>} ->
			1;
		{_, PageNum0} ->
			max(1, util_background:bitstring_to_integer(PageNum0))
	end,
	PageSize = 
	case lists:keyfind(<<"page_size">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma page_size missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{total_number,0},{desc, Desc},{data, <<>>}]}});
		{<<"page_size">>, <<>>} ->
			20;
		{_, PageSize0} ->
			max(1, util_background:bitstring_to_integer(PageSize0))
	end,
	StartRowIdx = (CurPage-1) * PageSize,
	LimitCond = " LIMIT " ++ integer_to_list(StartRowIdx) ++ "," ++ integer_to_list(PageSize),

	{ForbidStr, IsForbidCond} = 
	case lists:keyfind(<<"is_forbid">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma is_forbid missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{total_number,0},{desc, Desc},{data, <<>>}]}});
		{_, <<>>} ->
			{[], ""};
		{_, IsForbid0} ->
			{IsForbid0, " AND is_lock = ?"}
	end,

	OrderTypeStr = 
	case lists:keyfind(<<"order_type">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma order_type missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{total_number,0},{desc, Desc},{data, <<>>}]}});
		{_, OrderType0} ->
			 OrderType0
	end,

	OrderCond = 
	case lists:keyfind(<<"order_field">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma order_field missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{total_number,0},{desc, Desc},{data, <<>>}]}});
		{_, <<>>} ->
			"";
		{_, OrderField0} ->
			case OrderTypeStr of
				<<"1">> ->
					" ORDER BY ID DESC";
				_ ->
					" ORDER BY ID ASC"
			end
	end,

	case util_background:check_tick(ArgList) of
		false ->
			?ERR(?MODULE, "check flag error"),
			throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")},{total_number,0},{desc, Desc},{data, <<>>}]}});
		true ->
			ok
	end,

	CountSql = io_lib:format("SELECT COUNT(1) FROM gd_account WHERE 1=1~s~s~s~s~s~s",
		[NameCond, IDCond, AccountCond, IsOnlineCond, LastLoginIPCond, IsForbidCond]),
	case emysql:execute(mgserver_db_pool, CountSql, lists:flatten([NameStr, IDStr, AccountStr, IPStr, ForbidStr])) of
		{result_packet,_,_,[[Count]],_} ->
			Sql = io_lib:format("SELECT account,id,nick_name,register_time,level,login_ip,last_login_time,platform_id FROM gd_account WHERE 1=1~s~s~s~s~s~s~s~s",
				[NameCond, IDCond, AccountCond, IsOnlineCond, LastLoginIPCond, IsForbidCond, OrderCond, LimitCond]),
			?DBG(?MODULE, "Sql=~s", [Sql]),
			case emysql:execute(mgserver_db_pool, Sql, lists:flatten([NameStr, IDStr, AccountStr, IPStr, ForbidStr])) of
				{result_packet,_,_,Result,_} ->
					%% 这里如果返回的是[],到时候看看有没有问题
					Data = paseResult(Result),
					{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")},{total_number, Count},{data, Data},{desc, Desc}]};
				_ ->
					{struct, [{code, <<"9001">>},{message, unicode:characters_to_binary("系统错误")},{total_number, 0},{data, <<>>},{desc, Desc}]}
			end;
		_ ->
			{struct, [{code, <<"9001">>},{message, unicode:characters_to_binary("系统错误")},{total_number, 0},{data, <<>>},{desc, Desc}]}
	end.

paseResult([[Account,AccountID,RoleName,RegTime,Level,LastLoginIP,LastLoginTime,Country1]|Rest]) ->
	Country = util_config:get_platform_name(Country1),
	Result = {struct, [
					   {account, Account},{user_id, AccountID},{user_name, RoleName},{reg_time, list_to_binary(util:unixtime_to_timestamp(RegTime))},
					   {level, Level},{last_login_ip, LastLoginIP},{last_login_time, list_to_binary(util:unixtime_to_timestamp(LastLoginTime))},{country, Country}
					  ]},
	RestResult = paseResult(Rest),
	[Result|RestResult];
paseResult([]) ->
	[].

get_online_cond() ->
	case ets:tab2list(ets_online) of
		[] ->
			%% 其实是为了让其找不到数据
			" AND ID = 0";
		OnlineList ->
			get_online_cond(OnlineList, " AND ID IN (")
	end.

get_online_cond([{AccountID, _}], CondStr) ->
	CondStr ++ integer_to_list(AccountID) ++ ")";
get_online_cond([{AccountID, _}|Rest], CondStr) ->
	NewCondStr = CondStr ++ integer_to_list(AccountID) ++ ",",
	get_online_cond(Rest, NewCondStr).
