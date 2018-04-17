-ifndef(__LOG_HRL__).
-define(__LOG_HRL__, true).

-ifdef(__LOG_DEBUG__).


-define(DBG(Tag, Fmt),       lager:log_2(debug,[{tag, Tag}], Fmt)).
-define(DBG(Tag, Fmt, Args), lager:log_2(debug,[{tag, Tag}], Fmt, Args)).

-define(INF(Tag, Fmt, Args), lager:log_2(info,[{tag, Tag},{module,?MODULE},{line,?LINE}], util:color_fmt(Fmt), util:color_format("\e[35m~p\e[0m",Args))).
-define(INF(Tag, Fmt), lager:log_2(info,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt)).

-define(NTC(Tag, Fmt),       lager:log_2(notice,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt)).
-define(NTC(Tag, Fmt, Args), lager:log_2(notice,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt, Args)).

-define(WRN(Tag, Fmt),       lager:log_2(warning,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt)).
-define(WRN(Tag, Fmt, Args), lager:log_2(warning,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt, Args)).

-define(ERR(Tag, Fmt, Args), lager:log_2(error,[{tag, Tag},{module,?MODULE},{line,?LINE}], util:color_fmt(Fmt), util:color_format("\e[31m~p\e[0m",Args))).
-define(ERR(Tag, Fmt), lager:log_2(error,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt)).

-define(CRT(Tag, Fmt),       lager:log_2(critical,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt)).
-define(CRT(Tag, Fmt, Args), lager:log_2(critical,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt, Args)).

-define(ALT(Tag, Fmt),       lager:log_2(alert,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt)).
-define(ALT(Tag, Fmt, Args), lager:log_2(alert,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt, Args)).

-define(EMG(Tag, Fmt),       lager:log_2(emergency,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt)).
-define(EMG(Tag, Fmt, Args), lager:log_2(emergency,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt, Args)).


-define(PT_IN(Cmd,Format,Args),				 lager:proto_log_in_jj(Cmd,Format,Args)).
-define(PT_OUT(Cmd,Format,Args),			 lager:proto_log_out_jj(Cmd,Format,Args)).

-endif.




-ifndef(__LOG_DEBUG__).


-define(DBG(Tag, Fmt),       lager:log(debug,[{tag, Tag}], Fmt)).
-define(DBG(Tag, Fmt, Args), lager:log(debug,[{tag, Tag}], Fmt, Args)).

-define(INF(Tag, Fmt),       lager:log(info,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt)).
-define(INF(Tag, Fmt, Args), lager:log(info,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt, Args)).

-define(NTC(Tag, Fmt),       lager:log(notice,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt)).
-define(NTC(Tag, Fmt, Args), lager:log(notice,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt, Args)).

-define(WRN(Tag, Fmt),       lager:log(warning,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt)).
-define(WRN(Tag, Fmt, Args), lager:log(warning,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt, Args)).

-define(ERR(Tag, Fmt),       lager:log(error,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt)).
-define(ERR(Tag, Fmt, Args), lager:log(error,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt, Args)).

-define(CRT(Tag, Fmt),       lager:log(critical,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt)).
-define(CRT(Tag, Fmt, Args), lager:log(critical,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt, Args)).

-define(ALT(Tag, Fmt),       lager:log(alert,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt)).
-define(ALT(Tag, Fmt, Args), lager:log(alert,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt, Args)).

-define(EMG(Tag, Fmt),       lager:log(emergency,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt)).
-define(EMG(Tag, Fmt, Args), lager:log(emergency,[{tag, Tag},{module,?MODULE},{line,?LINE}], Fmt, Args)).

-define(PT_IN(Cmd,Format,Args),				 lager:proto_log_in_normal(Cmd,Format,Args)).
-define(PT_OUT(Cmd,Format,Args),			 lager:proto_log_out_normal(Cmd,Format,Args)).

-endif.





-endif.
