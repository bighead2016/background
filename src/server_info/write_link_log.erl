-module(write_link_log).

% -include("log.hrl").
% -include("log_type.hrl").
% -include("log_monitor.hrl").
% -include("account.hrl").
% -include("counter.hrl").

% -export([init/3]).
% -export([handle/2]).
% -export([terminate/3]).

% init(_Transport, Req, []) ->
% 	{ok, Req, undefined}.

% handle(Req, State) ->

%     % %% 读取客户端IP
%     % {{IP, Port}, _} = cowboy_req:peer(Req),
%     % %% 读取请求内容
%     % case cowboy_req:qs_vals(Req) of
%     %     {undefined, Req1} ->
%     %         ?ERR(background, "fail:can not find any field!!!!, IP=~p", [IP]),
%     %         Result = <<"fail:can not find any field!!!!">>;
%     %     {ContentList, Req1} ->
%     %     	?DBG(background, "Info=~p", [ContentList]),
%     %     	RoleIDTuple = lists:keyfind(<<"role_id">>, 1, ContentList),
%     %         AccountNameTuple = lists:keyfind(<<"account_name">>, 1, ContentList),
%     %         StepTuple = lists:keyfind(<<"step">>, 1, ContentList),
%     %         OSTuple = lists:keyfind(<<"os">>, 1, ContentList),
%     %         OSVersionTuple = lists:keyfind(<<"os_version">>, 1, ContentList),
%     %         DeviceTuple = lists:keyfind(<<"device">>, 1, ContentList),
%     %         DeviceTypeTuple = lists:keyfind(<<"device_type">>, 1, ContentList),
%     %         ScreenTuple = lists:keyfind(<<"screen">>, 1, ContentList),
%     %         MNOTuple = lists:keyfind(<<"mno">>, 1, ContentList),
%     %         NMTuple = lists:keyfind(<<"nm">>, 1, ContentList),

%     %         ?DBG(background, "Info=~p", [[RoleIDTuple, AccountNameTuple, StepTuple, OSTuple, OSVersionTuple, DeviceTuple, DeviceTypeTuple, ScreenTuple, MNOTuple, NMTuple]]),

%     %         case RoleIDTuple == false orelse AccountNameTuple == false orelse StepTuple == false orelse  OSTuple == false 
%     %           orelse OSVersionTuple == false orelse DeviceTuple == false orelse  DeviceTypeTuple == false 
%     %           orelse ScreenTuple == false orelse MNOTuple == false orelse NMTuple == false of
%     %         	true ->
%     %                 ?DBG(background, "fail:can not find any field!!!!, IP=~p", [IP]),
%     %         		Result = <<"fail:some necessary fields not found!!!!">>;
%     %         	false ->
%     %     			% {<<"role_id">>, RoleIDStr} = RoleIDTuple,
%     %     			{<<"account_name">>, AccountNameStr} = AccountNameTuple,
%     %                 case AccountNameTuple of
%     %                     {<<"account_name">>, AccountNameStr} when AccountNameStr == <<>> ->
%     %                         RoleID = 0;
%     %                     {<<"account_name">>, AccountNameStr} ->
%     %                         RoleID =
%     %                         case ets:lookup(ets_name_id_map, AccountNameStr) of
%     %                             [] ->
%     %                                 0;
%     %                             [NameIDMap] ->
%     %                                 NameIDMap#name_id_map.id
%     %                         end
%     %                 end,
%     %     			{<<"step">>, StepStr} = StepTuple,
%     %     			{<<"os">>, OSStr} = OSTuple,
%     %     			{<<"os_version">>, OSVersionStr} = OSVersionTuple,
%     %     			{<<"device">>, DeviceStr} = DeviceTuple,
%     %     			{<<"device_type">>, DeviceTypeStr} = DeviceTypeTuple,
%     %     			{<<"screen">>, ScreenStr} = ScreenTuple,
%     %     			{<<"mno">>, MNOStr} = MNOTuple,
%     %     			{<<"nm">>, NMStr} = NMTuple,

%     %                 ?DBG(background, "fail:can not find any field!!!!, IP=~p, account_name=~p, step=~p", [IP, AccountNameStr, StepStr]),

% 		  %           LogLinkRec = #log_link{
% 		  %                           role_id = RoleID, %util_background:bitstring_to_integer(RoleIDStr),
% 		  %                           account_name = AccountNameStr,
% 		  %                           step = util_background:bitstring_to_integer(StepStr),
% 		  %                           link_ip = util:change_ip_to_bitstring(IP),
% 		  %                           os = OSStr,
% 		  %                           os_version = OSVersionStr,
% 		  %                           device = DeviceStr,
% 		  %                           device_type = DeviceTypeStr,
% 		  %                           screen = ScreenStr,
% 		  %                           mno = MNOStr,
% 		  %                           nm = NMStr,
% 		  %                           happend_time=util:unixtime()
% 		  %                           },
%     % 				log_monitor:write_user_log(LogLinkRec),
%     %                 Result = <<"success:write log success!!!!">>
%     %         end
%     % end,
%     Req1 = Req,
%     Result = <<"success:write log success!!!!">>,
% 	{_, Req2} = cowboy_req:reply(200, [{<<"content-encoding">>, <<"utf-8">>}], Result, Req1),

% 	{ok, Req2, State}.

% terminate(_Reason, _Req, _State) ->
% 	ok.