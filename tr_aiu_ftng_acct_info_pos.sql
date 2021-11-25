/**
 * -----------------------------------------------------------------------
 * This trigger checks if updated position is of instance T_CFT_CASH_POSITION
 * [or] T_INITIAL_MARGIN_POSITION with aggregation level 1.
 * -----------------------------------------------------------------------
 */

PROMPT ------------------------------------------------------------------;
PROMPT $Id$
PROMPT ------------------------------------------------------------------;

exec registration.register ( -
    registration.trigger_code, -
    upper ('tr_aiu_ftng_acct_info_pos'), -
    '$Id$');

create or replace TRIGGER tr_aiu_ftng_acct_info_pos
AFTER
INSERT OR UPDATE
ON POSITION
REFERENCING OLD AS old NEW AS new
FOR EACH ROW
DECLARE
    cp T_CFT_CASH_POSITION;
    ip T_INITIAL_MARGIN_POSITION;
BEGIN
    -- $Id$
    IF :new.OBJECT_VALUE IS OF (T_CFT_CASH_POSITION)
    THEN
        cp := TREAT(:new.OBJECT_VALUE AS T_CFT_CASH_POSITION);

        IF cp.pk.aggregation_level <> 1
        THEN
            RETURN;
        END IF;

        ftng_svc_pusher.push_account_info(
            TREAT(cp.pk AS T_CFT_CASH_POSITION_KEY).getAccountNo()
        );
    END IF;

    IF :new.OBJECT_VALUE IS OF (T_INITIAL_MARGIN_POSITION)
    THEN
        ip := TREAT(:new.OBJECT_VALUE AS T_INITIAL_MARGIN_POSITION);

        IF ip.pk.aggregation_level <> 1
        THEN
            RETURN;
        END IF;

        ftng_svc_pusher.push_account_info(
            TREAT(cp.pk AS T_IM_POSITION_KEY).getAccountNo()
        );
    END IF;
END;
/

SHOW ERRORS
EXIT
