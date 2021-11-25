/**
 * ----------------------------------------------------------------------------
 * The trigger gets fired when column VALUE is updated.
 * Pushing is required for KEY changes to Credit, IntCredit,MargCorr,CashCorr,MargLim.
 * ----------------------------------------------------------------------------
 */

PROMPT ------------------------------------------------------------------;
PROMPT $Id$
PROMPT ------------------------------------------------------------------;

exec registration.register ( -
    registration.trigger_code, -
    upper ('tr_aiu_ftng_eca_acct_info'), -
    '$Id$');

create or replace TRIGGER tr_aiu_ftng_eca_acct_info
AFTER
INSERT OR UPDATE
OF VALUE
ON EXT_CASH_ACCOUNT_ATTRIBUTES
REFERENCING OLD AS old NEW AS new
FOR EACH ROW
WHEN(   new.ATTRIBUTE_TYPE = 'CACC_KRDB' AND new.KEY IN ('Credit', 'IntCredit')
     OR new.ATTRIBUTE_TYPE = 'CACC_TRAD' AND new.KEY IN ('MargCorr', 'CashCorr')
     OR new.ATTRIBUTE_TYPE = 'CACC_KIM'  AND new.KEY = 'MargLim'
    )
DECLARE
    account_no usertype.ACCOUNT_NO;
BEGIN
    -- $Id$
    -- Before push requested account number must be retrieved.
    account_no := usersession.get_context_value(ftng_types.ctx_val_account_no);
    -- If account_no is null then the following select returns account number for margin account from EXT_CASH_ACCOUNT_ATTRIBUTES

    IF account_no IS NULL
    THEN
        SELECT ACCOUNT_NO INTO account_no
        FROM   EXT_ACCOUNT_ATTRIBUTES eaa
        WHERE  ATTRIBUTE_TYPE = 'ACCT_KIM'
           AND KEY = 'MargAccNo'
           AND VALUE = :new.CASH_ACCOUNT_NO;
    END IF;
        -- Request push
        ftng_svc_pusher.push_account_info(account_no);
END;
/

SHOW ERRORS
EXIT
