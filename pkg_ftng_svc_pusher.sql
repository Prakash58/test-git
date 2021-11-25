PROMPT ------------------------------------------------------------------;
PROMPT $Id$
PROMPT ------------------------------------------------------------------;

exec registration.register ( -
    registration.package_body, -
    upper ('ftng_svc_pusher'), -
    '$Id$');

CREATE OR REPLACE PACKAGE BODY ftng_svc_pusher
AS
   /**
    * The procedure creates a new FTNGPusherPositionEntity.
    * Determining real broadcast mode would require us to read from pushed view
    * as there is some logic that decides if a position is contained in the view or not.
    * @param p_account_no usertype.ACCOUNT_NO Account number of entity to push.
    * @param p_contract_key FO_CONTRACT.CONTRACT_KEY%TYPE Contract key of entity to push.
    */
    PROCEDURE push_position(
        p_account_no   IN usertype.ACCOUNT_NO,
        p_contract_key IN FO_CONTRACT.CONTRACT_KEY%TYPE
    )
    IS
        p FTNGPusherPositionEntity;
    BEGIN
        p := new FTNGPusherPositionEntity(
                    "mode"    => broadcast.mode_update,
                    keyValues => new T_VARCHAR2_TABLE(TRIM(p_account_no), p_contract_key)
                 );

        IF session_store.object_store.get(p) IS NULL
        THEN
            session_store.object_store.put(p);
        END IF;
    END push_position;

    /**
     * Sending push messages for account info depends on several tables and calculations.
     * To cover all these dependencies triggers are used.These triggers calls
     * ftng_svc_push.push_account_info which builds Pusher Account Entity and cares for de-duplication.
     */
    PROCEDURE push_account_info(
        p_account_no IN usertype.ACCOUNT_NO
    )
    IS
       p FTNGPusherAccountEntity;
    BEGIN
        p := new FTNGPusherAccountEntity(
                    "mode"    => broadcast.mode_update,
                    keyValues => new T_VARCHAR2_TABLE(TRIM(p_account_no))
                 );

        IF session_store.object_store.get(p) IS NULL
        THEN
            session_store.object_store.put(p);
        END IF;
    END push_account_info;

END ftng_svc_pusher;
/

SHOW ERROR
EXIT
