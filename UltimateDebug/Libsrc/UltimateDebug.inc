    COMPILE('****ASCII',_C60_)
                                        PRAGMA ('link (C%V%ASC%X%%L%.LIB)')
	!END-COMPILE('****ASCII',_C60_)
    OMIT('****ASCII',_C60_)
    INCLUDE('_ver_.inc')  !sets _VER_ based on the CW version
LinkClass_Ascii                         CLASS,TYPE,LINK('C' & _VER_ & 'ASCX.LIB'); END  !Purpose is to link in the ASCII driver
	!END-OMIT('****ASCII',_C60_)

    OMIT('_EndOfInclude_',_UltimateDebug_)
_UltimateDebug_                         EQUATE(1)
!
!------------------------------------
!ClarionLive Ultimate Debug Class
!Category: Clarion Live!
!
!Debug class to send messages to DebugView, available at http://technet.microsoft.com/en-us/sysinternals/bb896647  
!
!Code contributed by:
!     Mike Hanson
!     Mark Goldberg
!     John Hickey
!     Skip Williams see http://www.clarionmag.com/cmag/v5/v5n01debuger.html
!                                                                            
!Class Methods:
!
!     Debug(<string>) - Send any string to the debug window
!     DebugQueue(<queue>,<string>) - Display the contents of a queue
!     DebugEvent - Use to display events and additional useful information
!     DebugClear - Clears the DebugView window  
!
!Class Properties
!
!     DebugOff - TRUE to turn debugging off, FALSE to turn debugging on
!     DebugPrefix - Used to filter Debug messages, prepended to the Output String
!     SaveToFile - if TRUE, will save debug messages to an ASCII file                           
!     ASCIIFileName - name of ASCII file to save debug messages to, default is 'Debug.txt'
!--------------------------------------------------------------------------------

ST::DebugEventQueue                     QUEUE,TYPE
Date                                        STRING(10)
Time                                        STRING(10)
EventNo                                     SIGNED
EventName                                   CSTRING(31)
FieldFeq                                    SIGNED
FieldName                                   CSTRING(31)
Keycode                                     UNSIGNED
StarDate                                    REAL
                                        END

DebugCategoryQueue                      QUEUE,TYPE
Category                                    STRING(40)
                                        END


GlobalASCIIFileName                     STRING('DebugLog.Txt')

!If you want a prefix to be included in the beginning of each debug string,
!then copy this to your application directory, and edit it as desired.
ST::DEBUG:Prefix                        EQUATE('!')
ST::DEBUG:Debugging                     EQUATE(1)  

qtUserEventName                         QUEUE,TYPE
EventEquate                                 LONG
EventName                                   CSTRING(40) !~Mar/19/08 MG
                                        END 

udKeyState:Shift                        EQUATE(0100h) !Shift key is pressed
udKeyState:Ctrl                         EQUATE(0200h) !Ctrl key is pressed
udKeyState:Alt                          EQUATE(0400h) !Alt key is pressed
udKeyState:EnterOnNum                   EQUATE(0800h) !Num Pad Enter Key, n/a with MESSAGE()
udKeyState:CapsLock                     EQUATE(1000h) !Caps Lock is On
udKeyState:NumLock                      EQUATE(2000h) !Num Lock is On
udKeyState:ScrollLock                   EQUATE(4000h) !Scroll Lock is On
udKeyState:InsertKey                    EQUATE(8000h) !Insert Mode is On,

!--------------------------------------------------------------------------------
UltimateDebug                           CLASS,TYPE,MODULE('UltimateDebug.CLW'),LINK('UltimateDebug.CLW')  !,_ABCLinkMode_),DLL(_ABCDllMode_)
!
!--------------------------------------------------------------------------------
! Add properties here, which are variables
!--------------------------------------------------------------------------------
!Properties
!----------
DebugOff                                    BOOL(FALSE)  
ProcedureInfoToDebugView                    BOOL(FALSE)
!DebugLog            BOOL(FALSE)  
DebugPrefix                                 STRING(20)
SaveToFile                                  BOOL(FALSE)
ASCIIFileName                               STRING('DebugLog.Txt')
DebugNoCR                                   BOOL(FALSE)

DebugEvent                                  SIGNED
HotKey                                      UNSIGNED
PurgeStarTime                               REAL
EventQ                                      &ST::DebugEventQueue
IgnoreEventQ                                &ST::DebugEventQueue

CategoryQueue                               &DebugCategoryQueue

                                            
EventOffset                                 LONG      
UserEventNameQ                              &qtUserEventName  

ShowAll                                     Bool
ShowField                                   Bool
ShowFocus                                   Bool
ShowSelected                                Bool
ShowSelStart                                Bool
ShowSelEnd                                  Bool
ShowKeyCode                                 Bool
ShowError                                   Bool
ShowThread                                  Bool
ShowContents                                Bool
ShowScreenText                              Bool
ShowAcceptAll                               Bool  

ProcAlertKey                                LONG
!
!--------------------------------------------------------------------------------
! Add Methods here, which are just procedures or functions
!--------------------------------------------------------------------------------
!Methods
!-------
      

Init                                        PROCEDURE()
Kill                                        PROCEDURE()
AddCategoryToDebug                          PROCEDURE(STRING pCategory)
AddUserEvent                                PROCEDURE(STRING argEventName,Long argEventEquate)
CalcStarDate                                PROCEDURE(<LONG D>,<LONG T>),REAL,PRIVATE
Construct                                   PROCEDURE()  
!!Debug                                       PROCEDURE(STRING pCategory,STRING pDebugString)  ! blah blah blah
Debug                                       PROCEDURE(STRING pDebugString,<STRING pCustomPrefix>,BYTE pNoClip = 0)
ClearDebugView                              PROCEDURE()
DebugEvent                                  PROCEDURE(<STRING pDebugProcedure>)  
GPF                                         PROCEDURE()
DebugGroup                                  PROCEDURE(*GROUP pGroup,<*GROUP pGroup2>,STRING pMsg,<STRING pStructureType>)
DebugGroup                                  PROCEDURE(*GROUP pGroup,STRING pMsg,<STRING pStructureType>)
DebugQueue                                  PROCEDURE(*QUEUE pQueue,<STRING pMsg>,<BYTE pNoTouch>)
DebugRecord                                 PROCEDURE(*FILE pFile,STRING pMsg)
DebugRecord                                 PROCEDURE(*FILE pFile1,*FILE pFile2,STRING pMsg)
Destruct                                    PROCEDURE()
FormatMessageList                           PROCEDURE(STRING pMsg,*QUEUE pMsgQueue)  
GetEventDescr                               PROCEDURE(LONG   argEvent=-1),STRING,PRIVATE !defaults to EVENT()
GetEventName                                PROCEDURE(SIGNED Event),STRING,PRIVATE
GetFEQDescr                                 PROCEDURE(SIGNED argFEQ=-1  ),STRING,PRIVATE !defaults to FIELD()
GetUserEvent                                PROCEDURE(LONG argEventEquate),STRING,PRIVATE   
HuntForOffset                               PROCEDURE(),private
IgnoreEvent                                 PROCEDURE(SIGNED Event)
LogEvent                                    PROCEDURE   
Message                                     PROCEDURE(STRING pDebugString)
SendOutputToDebug                           PROCEDURE(STRING pOutput,<STRING pCustomPrefix>,BYTE pNoClip = 0)
SetApplicationName                          PROCEDURE(STRING pApplicationName,STRING pProgramExtension),STRING
SetShortApplicationName                     PROCEDURE(STRING pApplicationName,STRING pProgramExtension),STRING
SetDebugEvent                               PROCEDURE(SIGNED DebugEvent)
SetEventOffSet                              PROCEDURE(),private
SetHotKey                                   PROCEDURE(UNSIGNED HotKey)
SetPurgeTime                                PROCEDURE(LONG DebugPurge)
ShowProcedureInfo                           PROCEDURE(STRING pProcedure,STRING pApplication,STRING pHelpID,STRING pCreated,STRING pModified,STRING pCompiled)
TakeEvent                                   PROCEDURE
                                        END       

!END-OMIT('_EndOfInclude_',_UltimateDebug_)
