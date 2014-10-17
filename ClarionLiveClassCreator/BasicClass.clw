                    MEMBER()
    omit('***',_c55_)
_ABCDllMode_        EQUATE(0)
_ABCLinkMode_       EQUATE(1)
    ***
!
!--------------------------
!ClarionLive! Basic Class Template
!--------------------------

    INCLUDE('EQUATES.CLW')
    INCLUDE('BasicClass.INC'),ONCE
    INCLUDE('UltimateDebug.inc'),ONCE



                    MAP
                    END

ud                  UltimateDebug

!----------------------------------------
BasicClass.Construct        PROCEDURE()
!----------------------------------------
    CODE
        
        ud.DebugOff = FALSE
        ud.DebugPrefix = '!'

        RETURN


!---------------------------------------
BasicClass.Destruct PROCEDURE()
!---------------------------------------
    CODE

        RETURN
        
        
!-----------------------------------
BasicClass.Init     PROCEDURE()
!-----------------------------------

    CODE

        RETURN

!-----------------------------------
BasicClass.Kill     PROCEDURE()
!-----------------------------------

    CODE

        RETURN



