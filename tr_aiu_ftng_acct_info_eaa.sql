/*
 * ----------------------------------------------------------------------------
 * The trigger gets fired when column VALUE is updated.
 * Pushing is required for changes to OverallBal and StckValRated.
 * ----------------------------------------------------------------------------
 */

PROMPT ------------------------------------------------------------------;
PROMPT $Id$
PROMPT ------------------------------------------------------------------;

exec registration.register ( -
    registration.trigger_code, -
    upper ('tr_aiu_ftng_acct_info_eaa'), -
    '$Id$');

create or replace TRIGGER tr_aiu_ftng_acct_info_eaa
AFTER
INSERT OR UPDATE
OF VALUE
ON EXT_ACCOUNT_ATTRIBUTES
REFERENCING OLD AS old NEW AS new
FOR EACH ROW
WHEN (new.ATTRIBUTE_TYPE = 'ACCT_KRDB' AND new.KEY IN ('OverallBal', 'StckValRated'))
DECLARE
    account_no usertype.ACCOUNT_NO;
BEGIN
    -- $Id$
    -- Request push. Affected account number is immediately available from trigger variable :new.
    ftng_svc_pusher.push_account_info(:new.account_no);
END;
/

SHOW ERRORS
EXIT

