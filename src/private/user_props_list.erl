-module(user_props_list).

-include("log.hrl").
-include("item.hrl").
-include("account.hrl").
-include("role.hrl").
-include("proto_const.hrl").

-export([handle/1]).
-compile(export_all).

handle(ArgList) ->
	Desc = {struct, [
					 {goodsid, unicode:characters_to_binary("道具ID")},
					 {count, unicode:characters_to_binary("道具数量")},
					 {position, unicode:characters_to_binary("道具位置")},
					 {goodsname, unicode:characters_to_binary("道具名称")},
					 {isbind, unicode:characters_to_binary("是否绑定")},
					 {level, unicode:characters_to_binary("道具等级")},
					 {color, unicode:characters_to_binary("道具颜色")}
					]},

	NameStr = 
	case lists:keyfind(<<"user_name">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma user_name missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{desc, Desc},{data, <<>>}]}});
		{_, Name0} ->
			Name0
	end,

	AccountStr = 
	case lists:keyfind(<<"account">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma account missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{desc, Desc},{data, <<>>}]}});
		{_, Account0} ->
			Account0
	end,

	AccountRec = 
	case lists:keyfind(<<"user_id">>, 1, ArgList) of
		false ->
			?ERR(?MODULE, "parma user_id missing"),
			throw({error, {struct, [{code, <<"1002">>},{message, unicode:characters_to_binary("参数错误")},{desc, Desc},{data, <<>>}]}});
		{_, <<>>} when AccountStr /= <<>> ->
			util_background:get_account_info_by_account(AccountStr, 0);
		{_, <<>>} when NameStr /= <<>> ->
			case ets:lookup(ets_nickname_id_map, NameStr) of
				[] ->
					none;
				[{_, AccountID}] ->
					util_background:get_account_info_by_id(AccountID)
			end;
		{_, <<>>} ->
			none;
		{_, ID0} ->
			AccountID = util_background:bitstring_to_integer(ID0),
			util_background:get_account_info_by_id(AccountID)
	end,

	case util_background:check_tick(ArgList) of
		false ->
			?ERR(?MODULE, "check flag error"),
			throw({error, {struct, [{code, <<"1001">>},{message, unicode:characters_to_binary("flag校验不通过")},{desc, Desc},{data, <<>>}]}});
		true ->
			ok
	end,

	Data =
	if
		AccountRec == none ->
			<<>>;
		% IDStr /= <<>> andalso AccountRec#account.id /= AccountID ->
		% 	<<>>;
		AccountStr /= <<>> andalso AccountRec#account.account /= AccountStr ->
			<<>>;
		NameStr /= <<>> andalso AccountRec#account.nick_name /= NameStr ->	
			<<>>;
		true ->
			ItemList = mod_item:get_items(AccountRec#account.id),
			Data1 = paseResult(ItemList),

			RoleList = mod_role:get_on_battle_roles(AccountRec#account.id),
			Data2 = paseResult2(RoleList),

			Data1++Data2
	end,

	{struct, [{code, <<"0">>},{message, unicode:characters_to_binary("操作成功")},{data, Data},{desc, Desc}]}.

paseResult([Item|Rest]) ->
	case Item#item.bag_type of
		?ITEM_BAG_TYPE_CONSTANT_NORMAL ->
			CfgItem = data_item:get(Item#item.cfg_id),
			GoodsName = unicode:characters_to_binary(CfgItem#cfg_item.name),
			Level = CfgItem#cfg_item.level,
			Color = get_item_color(CfgItem#cfg_item.quality),
			{AccountID, _} = Item#item.key,
			Position = get_item_position(AccountID, Item#item.role_id),
			IsBind = get_item_is_bind(Item#item.is_bind),
			StackNum = Item#item.stack_num,
			{_, GoodsID} = Item#item.key,
			Result = {struct, [
							   {goodsid, GoodsID},{count, StackNum},{position, Position},
							   {goodsname, GoodsName}, {isbind, IsBind},{level, Level},{color, Color}
							  ]},
			RestResult = paseResult(Rest),
			[Result|RestResult];
		_ ->
			paseResult(Rest)
	end;
paseResult([]) ->
	[].

paseResult2([Role|Rest]) -> [];
	% StoneList = Role#role.stones,
	% Position = list_to_binary(Role#role.name),
	% F = fun(StoneID, Acc) ->
	% 	CfgItem = data_item:get(StoneID),
	% 	GoodsName = list_to_binary(CfgItem#cfg_item.name),
	% 	Level = CfgItem#cfg_item.level,
	% 	Color = get_item_color(CfgItem#cfg_item.quality),
	% 	IsBind = get_item_is_bind(1),
	% 	StackNum = 1,
	% 	GoodsID = 0,
	% 	E = {struct, [
	% 					   {goodsid, GoodsID},{count, StackNum},{position, Position},
	% 					   {goodsname, GoodsName}, {isbind, IsBind},{level, Level},{color, Color}
	% 					  ]},
	% 	[E | Acc]
	% end,
	% Result = lists:foldl(F, [], StoneList),
	% RestResult = paseResult2(Rest),
	% Result ++ RestResult;
paseResult2([]) ->
	[].

get_item_color(1) ->
	unicode:characters_to_binary("白色");
get_item_color(2) ->
	unicode:characters_to_binary("绿色");
get_item_color(3) ->
	unicode:characters_to_binary("蓝色");
get_item_color(4) ->
	unicode:characters_to_binary("紫色");
get_item_color(5) ->
	unicode:characters_to_binary("橙色");
get_item_color(6) ->
	unicode:characters_to_binary("红色");
get_item_color(7) ->
	unicode:characters_to_binary("金色");
get_item_color(_) ->
	unicode:characters_to_binary("白色").

get_item_position(_AccountID, 0) ->
	unicode:characters_to_binary("背包");
get_item_position(AccountID, RoleID) ->
	Role = mod_role:get_role(AccountID, RoleID),
	#role_cfg{ name=Name } = data_role:get(RoleID),
	unicode:characters_to_binary(Name).

get_item_is_bind(0) ->
	unicode:characters_to_binary("否");
get_item_is_bind(_) ->
	unicode:characters_to_binary("是").


