-module(query_user_4_7725).

-include("log.hrl").
-include("log_type.hrl").
-include("account.hrl").

-export([handle/2]).

% http://192.168.1.3:9999/query_user_4_7725?loginName=f9978ce98e4e40b93e3ceb61a08121ee&pfcode=p7725&oprId=9100&sid=1
handle(ContentList, Req) ->
    case lists:keyfind(<<"pfcode">>, 1, ContentList) of
        {_, <<"p7725">>} ->
            ok;
        false ->
            ?ERR(?MODULE, "parma pfcode missing"),
            throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
        {_, PFCode0} ->
            ?ERR(?MODULE, "PFCode0 ~p /= <<\"p7725\">>", [PFCode0]),
            throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}})
    end,

    case lists:keyfind(<<"oprId">>, 1, ContentList) of
        {_, <<"9100">>} ->
            ok;
        false ->
            ?ERR(?MODULE, "parma oprId missing"),
            throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
        {_, OprID0} ->
            ?ERR(?MODULE, "PFCode0 ~p /= <<\"9100\">>", [OprID0]),
            throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}})
    end,

    ServerID =
    case lists:keyfind(<<"sid">>, 1, ContentList) of
        false ->
            ?ERR(?MODULE, "parma sid missing"),
            throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
        {_, ServerID0} ->
            util_background:bitstring_to_integer(ServerID0)
    end,

    SUID =
    case lists:keyfind(<<"loginName">>, 1, ContentList) of
        false ->
            ?ERR(?MODULE, "parma loginName missing"),
            throw({error, {struct, [{code, <<"3002">>},{message, <<"PARAMETER_NOT_LEGAL">>}]}});
        {_, SUID0} ->
            SUID0
    end,

    GameSys =
    case lists:keyfind(<<"game_sys">>, 1, ContentList) of
        false ->
            ?ERR(?MODULE, "parma game_sys missing"),
            throw({error, {struct, [{code, <<"3001">>},{message, <<"OTHER_ERROR">>}]}});
        {_, GameSys0} ->
            GameSys0
    end,

    PlatformID =
    case GameSys of
        <<"AND">> ->
            ?PF_TWAND_7725;
        <<"IOS">> ->
            ?PF_TWIOS
    end,
            
    % NormAccName = mod_account:normalize_account_name(AccName),
    case ets:lookup(ets_account_id_map, {SUID, ServerID, PlatformID}) of
        [] ->
            ?ERR(background, "can not find {SUID, ServerID, PlatformID} = ~p", [{SUID, ServerID, PlatformID}]),
            throw({error, {struct, [{code, <<"3001">>},{message, <<"USER_NOT_EXIST">>}]}});
        [{_, AccountID}] ->
            AccRec = mod_account:lookup_account(AccountID),
            NickName = AccRec#account.nick_name,
            Level = AccRec#account.level,
            WebPayLevel = 
            try
                data_system:get(133)
            catch _:_ ->
                0
            end,
            WebPay =
            case Level >= WebPayLevel of
                true ->
                    1;
                false ->
                    0
            end,
            {ok, {struct, [{<<"user_id">>,SUID}, {<<"player_id">>, AccountID}, {<<"player_name">>, NickName}, {<<"level">>, Level}, {<<"webpay">>, WebPay}]}}
    end.