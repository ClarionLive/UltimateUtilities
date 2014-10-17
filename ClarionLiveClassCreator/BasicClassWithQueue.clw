  MEMBER()

!--- these are usually set as project Defines
!omit('***',_c55_)
!_ABCDllMode_  EQUATE(0)
!_ABCLinkMode_ EQUATE(1)
!***
!
!--------------------------
!ClarionLive! Basic Class With Queue Template
!--------------------------

  INCLUDE('EQUATES.CLW')  !for ICON: and BEEP: etc.
! INCLUDE('KeyCodes.CLW')

  INCLUDE('BasicClassWithQueue.INC')

  MAP
  END

!----------------------------------------
BasicClassWithQueue.Construct    PROCEDURE()
!----------------------------------------
  CODE
  SELF.Q &= NEW qtIDDescr

  RETURN

!---------------------------------------
BasicClassWithQueue.Destruct    PROCEDURE()
!---------------------------------------
  CODE
  IF NOT(SELF.Q &= NULL)
     SELF.QFree()
     DISPOSE(SELF.Q)
  END

  RETURN


!-----------------------------------
BasicClassWithQueue.Init    PROCEDURE()
!-----------------------------------

  CODE

  SELF.InDebug = FALSE

  RETURN

!-----------------------------------
BasicClassWithQueue.Kill    PROCEDURE()
!-----------------------------------

  CODE

  RETURN

!-----------------------------------------
BasicClassWithQueue.HelloWorld    PROCEDURE()
!-----------------------------------------

  CODE

  BEEP(BEEP:SystemAsterisk)
  MESSAGE('Hello World From Clarion Live', 'Hello', ICON:ASTERISK)

  SELF.RaiseError('Display some kind of Error (only in Debug Mode)')

  RETURN

!---------------------------------------------------------
BasicClassWithQueue.RaiseError    PROCEDURE(STRING pErrorMsg)
!---------------------------------------------------------

  CODE

  IF SELF.InDebug = TRUE
    BEEP(BEEP:SystemExclamation)
    MESSAGE(CLIP(pErrorMsg), 'ClarionLive Error', ICON:EXCLAMATION)
  END

  RETURN

!---------------------------------------
BasicClassWithQueue.QFree           PROCEDURE()
!---------------------------------------
  CODE
  LOOP
    GET(SELF.Q, 1)
    IF ERRORCODE() THEN BREAK END
    SELF.QDel()
  END

!---------------------------------------
BasicClassWithQueue.QDel            PROCEDURE()
!---------------------------------------
!This method gives you an opportunity to DISPOSE of References in this Q (If are any)
  CODE
  DELETE(SELF.Q)

