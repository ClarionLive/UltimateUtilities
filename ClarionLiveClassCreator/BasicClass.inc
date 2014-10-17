    OMIT('_EndOfInclude_',_IFDef_BasicClass_)
_IFDef_BasicClass_  EQUATE(1)
!
!
!--------------------------------------------------------------------------------
BasicClass          CLASS,TYPE,MODULE('BasicClass.CLW'),LINK('BasicClass.CLW')   !,_ABCLinkMode_),DLL(_ABCDllMode_)
!
!Properties
!----------
!
!Methods
!-------
Init                    PROCEDURE()
Kill                    PROCEDURE()

Construct               PROCEDURE()
Destruct                PROCEDURE()
                    END


    _EndOfInclude_
