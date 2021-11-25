/*
 * -----------------------------------------------------------------------------
 * Each triggering point checks if the pre-condition is met, i.e.
 * if position touched is of correct instance and has correct aggregation level.
 * -----------------------------------------------------------------------------
 */

PROMPT ------------------------------------------------------------------;
PROMPT $Id$
PROMPT ------------------------------------------------------------------;

exec registration.register ( -
    registration.trigger_code, -
    upper ('tr_aiu_ftng_pos_position'), -
    '$Id$');

create or replace TRIGGER tr_aiu_ftng_pos_position
AFTER
INSERT OR UPDATE
ON POSITION
REFERENCING OLD AS old NEW AS new
FOR EACH ROW
DECLARE
    account_no   usertype.ACCOUNT_NO;
    contract_key FO_CONTRACT.CONTRACT_KEY%TYPE;
BEGIN
    -- $Id$
    IF :new.OBJECT_VALUE IS OF (T_CFT_POSITION)
       AND TREAT(:new.OBJECT_VALUE.pk AS T_CFT_POSITION_KEY).aggregation_level = 2
    THEN
        -- Get account_no and contract key
        account_no   := TREAT(:new.OBJECT_VALUE.pk AS T_CFT_POSITION_KEY).getAccountNo();
        contract_key := TREAT(:new.OBJECT_VALUE.pk AS T_CFT_POSITION_KEY).getInstrumentId();
        -- Request push
        ftng_svc_pusher.push_position(account_no, contract_key);
    END IF;
END;
/

SHOW ERRORS
EXIT
