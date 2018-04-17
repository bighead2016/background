-ifndef(__BACKGROUND_HRL__).
-define(__BACKGROUND_HRL__, true).

-define(ALLOW_CHARGE_IP_4_4399, [{192,168,24,203}]).
-define(ALLOW_CHARGE_IP_4_YY, [{192,168,24,203}]).
-define(SERVER_KEY, <<"zs123456">>).

-record(pay, {
				pay_id = 0,
				out_order_id = <<>>,
				platform = <<>>,
				platform_id = 0,
				platform_name = <<>>,
				suid = <<>>,
				role_id = 0,
				account_name = <<>>,
				server_id = 0,
				dim_level = 0,
				pay_type = 0,
				pay_money = 0,
				pay_gold = 0,
				status = 0,
				gash_type = <<>>,
				happend_time = 0
	}).

-endif.