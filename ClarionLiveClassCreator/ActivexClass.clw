                    MEMBER()

!--------------------------
!ClarionLive! Activex Class Template
!--------------------------

    INCLUDE('EQUATES.CLW')  !for ICON: and BEEP: etc.
! INCLUDE('KeyCodes.CLW')

    INCLUDE('ActivexClass.INC')

                    MAP
                    END

!----------------------------------------
ActivexClass.Construct      PROCEDURE()
!----------------------------------------
    CODE
        SELF.qActivex &= NEW queueType

        RETURN

!---------------------------------------
ActivexClass.Destruct       PROCEDURE()
!---------------------------------------
    CODE
        IF NOT(SELF.qActivex &= NULL)
            SELF.QFree()
            DISPOSE(SELF.qActivex)
        END

        RETURN


!-----------------------------------
ActivexClass.Init   PROCEDURE(LONG pActivexControl)
!-----------------------------------

    CODE

        SELF.ActivexControl = pActivexControl
        SELF.InDebug = FALSE

        RETURN

!-----------------------------------
ActivexClass.Kill   PROCEDURE()
!-----------------------------------

    CODE

        SELF.ActivexControl{PROP:Deactivate}
        
        RETURN

!-----------------------------------------
ActivexClass.HelloWorld     PROCEDURE()
!-----------------------------------------

    CODE

        BEEP(BEEP:SystemAsterisk)
        MESSAGE('Hello World From Clarion Live', 'Hello', ICON:ASTERISK)

        SELF.RaiseError('Display some kind of Error (only in Debug Mode)')

        RETURN

!---------------------------------------------------------
ActivexClass.RaiseError     PROCEDURE(STRING pErrorMsg)
!---------------------------------------------------------

    CODE

        IF SELF.InDebug = TRUE
            BEEP(BEEP:SystemExclamation)
            MESSAGE(CLIP(pErrorMsg), 'ClarionLive Error', ICON:EXCLAMATION)
        END

        RETURN

!---------------------------------------
ActivexClass.QFree  PROCEDURE()
!---------------------------------------
    CODE
        LOOP
            GET(SELF.qActivex, 1)
            IF ERRORCODE() THEN BREAK END
            SELF.QDel()
        END

!---------------------------------------
ActivexClass.QDel   PROCEDURE()
!---------------------------------------
!This method gives you an opportunity to DISPOSE of References in this Q (If are any)
    CODE
        DELETE(SELF.qActivex)

