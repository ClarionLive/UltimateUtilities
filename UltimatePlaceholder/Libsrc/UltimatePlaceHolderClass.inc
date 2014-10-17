!--------------------------------------------------------------------------------
UltimatePlaceholderControlClass   CLASS,TYPE,MODULE('UltimatePlaceholderClass.CLW'),LINK('UltimatePlaceholderClass.CLW',_UltimatePlaceholderLinkMode_),DLL(_UltimatePlaceholderDllMode_)
BoxFEQ                              SIGNED
EntryFEQ                            SIGNED
StringFEQ                           SIGNED
Text                                STRING(100)

InitWindow                          PROCEDURE(SIGNED pEntryFEQ,<STRING pText>) !,EXTENDS
Refresh                             PROCEDURE(),VIRTUAL
TakeEvent                           PROCEDURE(),VIRTUAL

                                  END

!--------------------------------------------------------------------------------
UltimatePlaceholderControlQueueType   QUEUE,TYPE
ControlObject                           &UltimatePlaceholderControlClass
                                      END

!--------------------------------------------------------------------------------
UltimatePlaceholderWindowClass    CLASS,TYPE,MODULE('UltimatePlaceholderClass.CLW'),LINK('UltimatePlaceholderClass.CLW',_UltimatePlaceholderLinkMode_),DLL(_UltimatePlaceholderDllMode_)
ControlQueue                        &UltimatePlaceholderControlQueueType

Construct                           PROCEDURE
Destruct                            PROCEDURE

AddControl                          PROCEDURE(SIGNED pEntryFEQ,<STRING pText>) !,EXTENDS
Refresh                             PROCEDURE(),VIRTUAL
TakeEvent                           PROCEDURE(),VIRTUAL
                                  END

!--------------------------------------------------------------------------------
