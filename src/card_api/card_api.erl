-module(card_api).

% -include("log.hrl").
% -include("err_code.hrl").

% -export([handle/4]).

% handle(ServerID, Account, CardID, CardType) ->
% 	{ok, DBCenter} = application:get_env(background, db_center),
% 	Sql = "SELECT a.CardTypeid,a.CardState,a.StartTime,a.EndTime,b.ItemList FROM "++ DBCenter ++".card a,"++ DBCenter ++".card_type b 
% 			WHERE a.CardNumber=? AND a.CardTypeID=b.CardTypeID AND b.CardType=? AND (b.ServerID=? OR b.ServerID=0)", 
% 	try
% 		case emysql:execute(oceanus_pool,Sql,[CardID,CardType,ServerID]) of
% 			{result_packet,_,_,[],_} ->
% 				{fail, ?ERR_GIFT_CARD_NOT_EXIST};
% 			{result_packet,_,_,[[CardTypeID,IsUse,StartTime,EndTime,ItemList]],_} ->
% 				NowTime = util:unixtime(),
% 				if
% 					IsUse == 1 ->
% 						{fail, ?ERR_GIFT_CARD_ALEARDY_EXCHANGE};
% 					StartTime > NowTime ->
% 						{fail, ?ERR_GIFT_CARD_INACTIVE};
% 					EndTime < NowTime ->
% 						{fail, ?ERR_GIFT_CARD_INVALID};
% 					true ->
% 						SelSql = "SELECT COUNT(1) FROM "++ DBCenter ++".card WHERE CardTypeID=? AND ServerID=? AND UsedAccount=?",
% 						case emysql:execute(oceanus_pool,SelSql,[CardTypeID,ServerID,Account]) of
% 							{result_packet,_,_,[[Count]],_} when Count =< 0 ->
% 								UpdSql = "UPDATE "++ DBCenter ++".card SET CardState=1,ServerID=?,UsedAccount=? WHERE CardNumber=?",
% 								case emysql:execute(oceanus_pool,UpdSql,[ServerID,Account,CardID]) of
% 									{ok_packet,_,_,_,_,_,_} ->
% 										{ok, util:bitstring_to_term(ItemList)};
% 									Result ->
% 										?DBG(card, "sql err Result=~p", [Result]),
% 										{fail, ?ERR_GIFT_SYSTEM_ERROR}
% 								end;
% 							{result_packet,_,_,[[Count]],_} ->
% 								?ERR(card, "sql =~s", [SelSql]),
% 								{fail, ?ERR_GIFT_MEDIA_NOT_TIMES};
% 							Result1 ->
% 								?DBG(card, "sql err Result1=~p", [Result1]),
% 								{fail, ?ERR_GIFT_SYSTEM_ERROR}
% 						end
% 				end;
% 			_ ->
% 				?ERR(card, "sql err Sql=~s", [Sql]),
% 				{fail, ?ERR_GIFT_SYSTEM_ERROR}
% 		end
% 	catch ErrCode:ErrMsg ->
% 		?ERR(card, "ErrCode=~p, ErrMsg=~p", [ErrCode,ErrMsg]),
% 		{fail, ?ERR_GIFT_SYSTEM_ERROR}
% 	end.