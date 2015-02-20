                              MEMBER()
  omit('***',_c55_)
_ABCDllMode_                  EQUATE(0)
_ABCLinkMode_                 EQUATE(1)
  ***
!
!--------------------------
!ClarionLive Skeleton Class
!--------------------------
!==============================================================================
!If all fields begin with the same prefix, then you can have that auto-stripped
!by uncommenting the following line.
!E_StripPrefix                 EQUATE(1)
!==============================================================================
WidthMultiplier:Narrow        EQUATE(5)  !normal columns (numbers, lowercase, etc.)
WidthMultiplier:Wide          EQUATE(7)  !uppercase columns
DebugQueueCallingItself       BOOL(FALSE)
!==============================================================================
  INCLUDE('Equates.clw')
  INCLUDE('Errors.clw')
  INCLUDE('UltimateDebug.inc'),ONCE    
  INCLUDE('UltimateVLB.inc'),ONCE
! ToDo _wsldebug$setlogfile

                              MAP
                                module('kernel')     
!see http://msdn.microsoft.com/library/default.asp?url=/library/en-us/debug/base/debugging_functions.asp
                                  debugbreak(),PASCAL !,RAW,NAME('debugbreak')
                                  OutputDebugString(*CSTRING),PASCAL,RAW,NAME('OutputDebugStringA')
                                end  
                                MODULE('C%V%RUN%X%')
                                  debugerNameMessage (*CSTRING, UNSIGNED EventNum ),RAW,NAME('WslDebug$NameMessage')   !Note: use   Event() + EVENT:FIRST  else will get WM_*
                                  COMPILE('** C55+ **',_C55_)
                                  debugerGetFieldName(SIGNED FEQ            ),*CSTRING,RAW,NAME('Cla$FIELDNAME')
                                  !END-COMPILE('** C55+ **',_C55_)
                                  OMIT('** C55+ **',_C55_)
                                  debugerGetFieldName(SIGNED FEQ            ),LONG,RAW,NAME('Cla$FIELDNAME')
                                  !END-OMIT('** C55+ **',_C55_)
                                END
                              END

!OMIT('_ifdef_',EVENT:APP=08000h)
  COMPILE('_ifdef_',EVENT:APP=0)
EVENT:APP                     EQUATE(08000h)
EVENT:APP_LAST                EQUATE(0BFFFh)
  !END_COMPILE('_ifdef_',EVENT:APP=0)
!==============================================================================

!-----------------------------------
UltimateDebug.Init            PROCEDURE()
!-----------------------------------

  CODE
        
  RETURN

!-----------------------------------
UltimateDebug.Kill            PROCEDURE()
!-----------------------------------

  CODE

  RETURN
	
!-----------------------------------------
UltimateDebug.AddCategoryToDebug  PROCEDURE(STRING pCategory)
!-----------------------------------------

  CODE
	
  SELF.CategoryQueue.Category = pCategory
  GET(SELF.CategoryQueue,SELF.CategoryQueue.Category)
  IF ERROR()
    ADD(SELF.CategoryQueue,SELF.CategoryQueue.Category)
  END
	
		
!!!-----------------------------------------
!!UltimateDebug.Debug             PROCEDURE(STRING pCategory,STRING pDebugString)
!!!-----------------------------------------
!!
!!	CODE
!!	
!!	SELF.CategoryQueue.Category = pCategory
!!	GET(SELF.CategoryQueue,SELF.CategoryQueue.Category)
!!	IF ERRORCODE() = NoError
!!		SELF.Debug('[' & CLIP(pCategory) & ']' & pDebugString)
!!	END
!!	
!!	RETURN
!-----------------------------------------
UltimateDebug.Debug           PROCEDURE(STRING pDebugString,<STRING pCustomPrefix>,BYTE pNoClip = 0)
!-----------------------------------------
ASC1:ASCIIFile                  FILE,PRE(ASC1),DRIVER('ASCII'),NAME(GlobalASCIIFileName),CREATE
RECORD                            RECORD,PRE()
STRING                              STRING(512)
                                  END
                                END

lc_CDebugString                 STRING(10000)
lc_COutDebugString              STRING(10000)
lc_Temp                         STRING(10000)
ll_Count                        LONG
ll_End                          LONG
lb_Flag                         BYTE(FALSE)
lb_FirstTime                    BYTE(TRUE)
lb_FirstLoop                    BYTE(0)
ll_StringPosition               LONG


  CODE      
  IF SELF.DebugOff AND ~SELF.SaveToFile;RETURN.
	 
  GlobalASCIIFileName = SELF.ASCIIFileName
  IF SELF.SaveToFile
    IF ~EXISTS(ASC1:ASCIIFile{PROP:Name})
      CREATE(ASC1:ASCIIFile)
    END
    OPEN(ASC1:ASCIIFile)
  END	
  ll_Count = 1  
  IF SELF.DebugNoCR   
    lc_CDebugString = CLIP(pDebugString) 
    IF ~SELF.DebugOff 
      SELF.SendOutputToDebug(lc_CDebugString,pCustomPrefix,pNoClip)
    END  
    IF SELF.SaveToFile
      ASC1:String = '[' & FORMAT(TODAY(),@D17) & '-' & FORMAT(CLOCK(),@T7) & ']- ' & lc_CDebugString
      ADD(ASC1:ASCIIFile)
    END
  ELSE
    IF LEN(CLIP(pDebugString)) = 0
      IF SELF.SaveToFile
        ASC1:String = '[' & FORMAT(TODAY(),@D17) & '-' & FORMAT(CLOCK(),@T7) & ']'
        ADD(ASC1:ASCIIFile)
      END
      IF ~SELF.DebugOff
        lc_COutDebugString = ''
        SELF.SendOutputToDebug(lc_COutDebugString,pCustomPrefix,pNoClip)
      END
    ELSE
			
      Loop Until lb_Flag
        If Len(Clip(pDebugString)) - ll_Count < 9999 Then
          ll_end = Len(Clip(pDebugString))
          lb_Flag = True
        Else
          ll_end = ll_Count + 9998
        End         
        lc_CDebugString = CLIP(pDebugString[ll_Count : ll_end])
                        
        ll_Count = ll_end + 1
        LOOP
          ll_StringPosition = INSTRING('<13>',lc_CDebugString,1,1)

          IF ll_StringPosition                                      
            lc_COutDebugString = SUB(lc_CDebugString,1,ll_StringPosition - 1)
            lc_CDebugString = SUB(lc_CDebugString,ll_StringPosition + 2,10000)
            IF SELF.SaveToFile
              ASC1:String = '[' & FORMAT(TODAY(),@D17) & '-' & FORMAT(CLOCK(),@T7) & ']- ' & lc_COutDebugString
              ADD(ASC1:ASCIIFile)
            END
            IF ~SELF.DebugOff
              SELF.SendOutputToDebug(lc_COutDebugString,pCustomPrefix,pNoClip)
            END

            lb_FirstLoop = TRUE
            CYCLE
          END
          IF SELF.SaveToFile
            ASC1:String = '[' & FORMAT(TODAY(),@D17) & '-' & FORMAT(CLOCK(),@T7) & ']- ' & lc_CDebugString
            ADD(ASC1:ASCIIFile)
          END
          IF ~SELF.DebugOff
            SELF.SendOutputToDebug(lc_CDebugString,pCustomPrefix,pNoClip)
          END
          BREAK
        END 
      END
    END
  END
  IF SELF.SaveToFile
    CLOSE(ASC1:ASCIIFile)
  END

!-----------------------------------------------------------------------------------------!
UltimateDebug.SendOutputToDebug   PROCEDURE(STRING pOutput,<STRING pCustomPrefix>,BYTE pNoClip = 0)
!-----------------------------------------------------------------------------------------!

lc_CDebugString                     CSTRING(10000)
lc_COutDebugString                  CSTRING(10000)
lc_Temp                             CSTRING(10000)
Count                               LONG(0)

  CODE

  IF pNoClip
    lc_COutDebugString = CLIP(SELF.DebugPrefix) & pOutput
    OutputDebugString(lc_COutDebugString)
  ELSE
    lc_CDebugString =  CLIP(pOutput)
            
    LOOP
      Count += 1
      IF LEN(CLIP(lc_CDebugString)) > 160
        IF Count > 1
          lc_COutDebugString = '   ' & lc_CDebugString[1:160] 
        ELSE
          lc_COutDebugString = lc_CDebugString[1:160] 
        END
        lc_CDebugString = SUB(lc_CDebugString,161,10000)
                    
      ELSE
        lc_COutDebugString = lc_CDebugString
        lc_CDebugString = '' 
      END
                
                
      lc_COutDebugString = CLIP(SELF.DebugPrefix) & ' ' & CLIP(pCustomPrefix) & ' ' & CLIP(lc_COutDebugString)
      OutputDebugString(lc_COutDebugString)
                
      IF LEN(CLIP(lc_CDebugString)) = 0
        BREAK
      END
                
    END
            
  END
        
        
            

!-----------------------------------------------------------------------------------------!
UltimateDebug.ClearDebugView  PROCEDURE()   !Requires Debugview 4.3 or greater
!-----------------------------------------------------------------------------------------!
!From:  http://www.sysinternals.com/ntw2k/freeware/debugview.shtml
!       Clear-output string: When DebugView sees the special debug output string "DBGVIEWCLEAR" it clears the output.

!Note: If this doesn't appear to work, then you are either:
!          a) using an older version of debugview
!       OR b) you are filtering the message

  CODE

  SELF.Debug('DBGVIEWCLEAR')
	
		
	
!==============================================================================
UltimateDebug.DebugRecord     PROCEDURE(*FILE pFile,STRING pMsg)
!--------------------------------------
G                               &GROUP
!--------------------------------------
  CODE
  IF SELF.DebugOff;RETURN.
  COMPILE('!ENDCOMPILE', ST::DEBUG:Debugging=1)
  G &= pFile{PROP:Record}
  SELF.DebugGroup(G,, pMsg, 'Record')
  !ENDCOMPILE
  RETURN
!==============================================================================
UltimateDebug.DebugRecord     PROCEDURE(*FILE pFile,*FILE pFile2,STRING pMsg)
!--------------------------------------
G1                              &GROUP
G2                              &GROUP
!--------------------------------------
  CODE
  IF SELF.DebugOff;RETURN.
  COMPILE('!ENDCOMPILE', ST::DEBUG:Debugging=1)
  G1 &= pFile{PROP:Record}
  G2 &= pFile2{PROP:Record}
  SELF.DebugGroup(G1, G2, pMsg, 'Record')
  !ENDCOMPILE
  RETURN
!==============================================================================
UltimateDebug.DebugGroup      PROCEDURE(*GROUP pGroup,STRING pMsg,<STRING pStructureType>)
!--------------------------------------
  CODE
  IF SELF.DebugOff;RETURN.
  COMPILE('!ENDCOMPILE', ST::DEBUG:Debugging=1)
  SELF.DebugGroup(pGroup,, pMsg)
  !ENDCOMPILE
  RETURN
!==============================================================================
UltimateDebug.DebugGroup      PROCEDURE(*GROUP pGroup,<*GROUP pGroup2>,STRING pMsg,<STRING pStructureType>)
!--------------------------------------
epGroup2                        EQUATE(2)
SavePointer                     LONG,AUTO
NumFields                       SHORT(0)
NumFields2                      SHORT(0)
FieldQ                          QUEUE
Name                              CSTRING(100)
Value                             CSTRING(1000)
Value2                            CSTRING(1000)
                                END
MsgLineQ                        QUEUE
Text                              STRING(100)
                                END
!--------------------------------------
Window                          WINDOW('Debug'),AT(,,676,416),FONT('Tahoma',8,,),CENTER,SYSTEM,GRAY,DOUBLE
                                  LIST,AT(4,4,668,356),USE(?DebugList),VSCROLL,FORMAT('125L(2)|M~Field Name~S(1)@S100@180L(2)|M~Value~S(1)@S255@1000L(2)|M~Value2~S(1)@' &|
                                      'S255@'),FROM(FieldQ)
                                  LIST,AT(4,364,668,48),USE(?MessageList),VSCROLL,FROM(MsgLineQ)
                                END
!--------------------------------------
  CODE
  IF SELF.DebugOff;RETURN.
  COMPILE('!ENDCOMPILE', ST::DEBUG:Debugging=1)
  DO LoadFieldQ
  !--- Prepare window
  OPEN(Window)
  IF OMITTED(epGroup2)
    ?DebugList{PROPLIST:Width, 2} = 1000
  END
  0{PROP:Text} = 0{PROP:Text} &' '& CHOOSE(pStructureType='', 'Group', pStructureType) &' ('& NumFields &' Fields)'
  IF pMsg
    SELF.FormatMessageList(pMsg, MsgLineQ)
  ELSE
    HIDE(?MessageList)
    ?DebugList{PROP:Height} = ?DebugList{PROP:Height} + ?MessageList{PROP:Height} + 4
  END
  !--- Display window
  ACCEPT
  END
  !ENDCOMPILE
  RETURN
!======================================
LoadFieldQ                    ROUTINE
!--------------------------------------
  DATA
F   ANY                  !Field reference for value assignment
X   SHORT,AUTO
M   SHORT(0)
!--------------------------------------
  CODE
  OMIT('!+++!!!+++!')
  LOOP X = 10000 TO 1 BY -1
    IF NumFields = 0 AND WHO(pGroup, X) <> ''
      NumFields = X
      IF M = 0
        M = NumFields
      END
    END
    IF NOT OMITTED(epGroup2)  |
        AND NumFields2 = 0 AND WHO(pGroup2, X) <> ''
      NumFields2 = X
      IF M = 0
        M = NumFields2
      END
    END
    IF M = 0 AND (NumFields OR NumFields2)
      M = X
    END
    IF NumFields AND (OMITTED(epGroup2) OR NumFields2)
      BREAK
    END
  END
  LOOP X = 1 TO M
    CLEAR(FieldQ)
    IF NumFields >= X
      FieldQ.Name   = WHO(pGroup, X)
      F            &= WHAT(pGroup, X, 1)
      FieldQ.Value  = F
      IF NumFields2 >= X
        DO AssignValue2
      END
    ELSE
      FieldQ.Name   = WHO(pGroup2, X)
      DO AssignValue2
    END
    ADD(FieldQ)
    ASSERT(ERRORCODE()=0)
  END
  !+++!!!+++!
  EXIT
!======================================
AssignValue2                  ROUTINE
!--------------------------------------
  OMIT('!+++!!!+++!')
  F            &= WHAT(pGroup2, X, 1)
  FieldQ.Value2 = F
  !+++!!!+++!
  EXIT
!==============================================================================
UltimateDebug.DebugQueue      PROCEDURE(*QUEUE pQueue,<STRING pMsg>,<BYTE pNoTouch>)
                              MAP
LoadFieldQ                      PROCEDURE
                              END
!--------------------------------------
SavePointer                     LONG,AUTO
NumFields                       SHORT,AUTO
                                COMPILE('***---***', E_StripPrefix)
StripPrefixLength               BYTE,AUTO
                                ***---***
StripedList                     UltimateVLB
StripedList_ColumnClass         CLASS(UltVLB:ColumnClass),TYPE
Init                              PROCEDURE(LONG FieldNo,*? FieldRef,STRING Header,STRING Picture,SHORT Width,STRING Justification)
                                END
DummyColumn                     STRING(1)
ColumnObj                       &StripedList_ColumnClass
FieldQ                          QUEUE
Header                            CSTRING(100)
Width                             LONG
IsNumeric                         BOOL
IsGroup                           BOOL
ColumnObject                      &UltVLB:ColumnClass
                                END
MsgLineQ                        QUEUE
Text                              STRING(1000)
                                END    
!NumberColumn                  CLASS(UltVLB:ColumnClass)
!Init                            PROCEDURE(LONG FieldNo,*? FieldRef,STRING Header,STRING Picture),*UltVLB:ColumnClass
!                              END
!--------------------------------------
Window                          WINDOW('Debug Queue'),SYSTEM,AT(,,676,416),CENTER,FONT('Tahoma', 8),GRAY,DOUBLE
                                  LIST, AT(4,4,668,356), USE(?DebugList), HVSCROLL
                                  LIST, AT(4,364,668,48), USE(?MessageList), VSCROLL, FROM(MsgLineQ)
                                END
!--------------------------------------
  CODE
  IF SELF.DebugOff;RETURN.
  !ST::Debug('ST::DebugQueue/IN')
  COMPILE('!ENDCOMPILE', ST::DEBUG:Debugging=1)
  IF pQueue &= NULL
    MESSAGE('Queue passed to ST::DebugQueue was a NULL pointer!', 'Debug Queue')
  ELSE
    !--- Save current queue pointer
    SavePointer = CHOOSE(RECORDS(pQueue)=0, 0, POINTER(pQueue))
    !--- Scan passed queue
    DO FindLastField
    IF NumFields = 0
      MESSAGE('Queue passed to ST::DebugQueue has no fields!', 'Debug Queue')
    ELSE
      LoadFieldQ
      COMPILE('***---***', E_StripPrefix)
      DO CheckStripPrefix
      ***---***
      !--- Prepare window
      OPEN(Window)
      0{PROP:Text} = 0{PROP:Text} &' ('& NumFields &' Fields, '& RECORDS(pQueue) &' Records)'
      DO FormatFieldList
      IF pMsg
        SELF.FormatMessageList(pMsg, MsgLineQ)
      ELSE
        HIDE(?MessageList)
        ?DebugList{PROP:Height} = ?DebugList{PROP:Height} + ?MessageList{PROP:Height} + 4
      END
      StripedList.Init(?DebugList, pQueue)
      SELF.Debug(?DebugList{PROP:Format})
      ?DebugList{PROP:Selected} = SavePointer
      IF NOT DebugQueueCallingItself
        DebugQueueCallingItself = TRUE
        !SELF.DebugQueue(FieldQ)
        DebugQueueCallingItself = FALSE
      END
      !--- Display window
      ACCEPT
      END
      !--- Restore queue pointer
      IF SavePointer <> 0 AND pNoTouch <> 1
        GET(pQueue, SavePointer)
      END
    END
  END
  DO FreeFieldQ
  !ENDCOMPILE
  !ST::Debug('ST::DebugQueue/OUT')
  RETURN
!======================================
FreeFieldQ                    ROUTINE
!--------------------------------------
  DATA
X   LONG
  CODE
!--------------------------------------
  LOOP X = 1 TO RECORDS(FieldQ)
    GET(FieldQ, X)
    DISPOSE(FieldQ.ColumnObject)
  END
  FREE(FieldQ)
  DISPOSE(ColumnObj)

!======================================
FindLastField                 ROUTINE
!--------------------------------------
  NumFields = 5000
  LOOP WHILE NumFields > 0  |
      AND   WHO(pQueue, NumFields) = ''
    NumFields -= 1
  END

!**************************************
  COMPILE('***---***', E_StripPrefix)
!======================================
CheckStripPrefix              ROUTINE
!--------------------------------------
  DATA
FieldNo SHORT,AUTO
PrefixFound CSTRING(20)
!--------------------------------------
  CODE
  LOOP FieldNo = 1 TO NumFields
    FieldQ.Header = WHO(pQueue, FieldNo)
    
    StripPrefixLength = INSTRING(':', FieldQ.Header)
    IF StripPrefixLength
      IF FieldNo = 1
        PrefixFound = FieldQ.Header[1:StripPrefixLength]
      ELSIF FieldQ.Header[1:StripPrefixLength] <> PrefixFound
        StripPrefixLength = 0
        BREAK
      END
    ELSIF PrefixFound
      StripPrefixLength = 0
      BREAK
    END
  END
  EXIT
  ***---***
!======================================
FormatFieldList               ROUTINE
!--------------------------------------
  DATA
FieldNo SHORT,AUTO
ColumnNo    SHORT(0)
Picture CSTRING(5)
!--------------------------------------
  CODE
  !?DebugList{PROP:From} = pQueue
  LOOP FieldNo = 1 TO NumFields
    GET(FieldQ, FieldNo)
    IF FieldQ.IsGroup
      CYCLE
    END
    ColumnNo += 1
    Picture = '@S'& FieldQ.Width
    ?DebugList{PROPLIST:Header                    , ColumnNo} = FieldQ.Header
    ?DebugList{PROPLIST:Picture                   , ColumnNo} = Picture
!   ?DebugList{PROPLIST:Width                     , ColumnNo} = FieldQ.Width
!   ?DebugList{PROPLIST:HeaderCenter              , ColumnNo} = True
!   ?DebugList{PROPLIST:HeaderLeft                , ColumnNo} = True
!   ?DebugList{PROPLIST:HeaderLeftOffset          , ColumnNo} = 1
!   IF FieldQ.IsNumeric
!     ?DebugList{PROPLIST:Right                 , ColumnNo} = True
!     ?DebugList{PROPLIST:RightOffset           , ColumnNo} = 1
!   ELSE
!     ?DebugList{PROPLIST:Left                  , ColumnNo} = True
!     ?DebugList{PROPLIST:LeftOffset            , ColumnNo} = 1
!   END
    ?DebugList{PROPLIST:FieldNo                   , ColumnNo} = FieldNo
!   ?DebugList{PROPLIST:RightBorder               , ColumnNo} = 1
    ?DebugList{PROPLIST:RightBorder+PROPLIST:Group, ColumnNo} = 1
!   ?DebugList{PROPLIST:Resize                    , ColumnNo} = 1

    ColumnObj &= NEW StripedList_ColumnClass
    ColumnObj.Init(FieldNo, WHAT(pQueue, FieldNo), FieldQ.Header, Picture, FieldQ.Width, CHOOSE(~FieldQ.IsNumeric, 'L', 'R'))
    FieldQ.ColumnObject &= ColumnObj
    PUT(FieldQ)
    StripedList.AddColumn(FieldQ.ColumnObject)
  END
  ColumnObj &= NEW StripedList_ColumnClass
  ColumnObj.Init(NumFields+1, DummyColumn, '', '@S1', 1, 'L')
  StripedList.AddColumn(ColumnObj)

!**************************************
!======================================
StripedList_ColumnClass.Init    PROCEDURE(LONG FieldNo,*? FieldRef,STRING Header,STRING Picture,SHORT Width,STRING Justification)
  CODE
  SELF.FieldNo       = FieldNo
  SELF.FieldRef     &= FieldRef
  SELF.Header        = Header
  SELF.Picture       = Picture
  SELF.Width         = Width
  SELF.Justification = Justification
  IF SELF.Justification = 'R'
    SELF.HJustification = 'C'
    SELF.HOffset        = 0
  END

!======================================
LoadFieldQ                    PROCEDURE
!--------------------------------------
FieldNo                         SHORT,AUTO
FieldRef                        ANY
RecNo                           LONG,AUTO
SampleLength                    LONG,AUTO
HeaderLength                    LONG,AUTO
DataLength                      LONG,AUTO
IsDataUpper                     BOOL,AUTO
!--------------------------------------
  CODE
  !ST::Debug('ST::DebugQueue/LoadFieldQ/IN: NumFields='& NumFields)
  LOOP FieldNo = 1 TO NumFields
    CLEAR(FieldQ)
    !ST::Debug('ST::DebugQueue/LoadFieldQ: FieldNo='& FieldNo)
    FieldQ.Header                  = LOWER(WHO(pQueue, FieldNo))
    COMPILE('***---***', E_StripPrefix)
    IF StripPrefixLength
      HeaderLength                 = LEN(FieldQ.Header) - StripPrefixLength
      FieldQ.Header                = SUB(FieldQ.Header, StripPrefixLength+1, HeaderLength)
    ELSE
      ***---***
      HeaderLength                 = LEN(FieldQ.Header)
      COMPILE('***---***', E_StripPrefix)
    END
    ***---***
    IF HeaderLength < 1
      HeaderLength                 = 1
    END
    COMPILE('***---***', _C60_)
    FieldRef                      &= WHAT(pQueue, FieldNo, 1)
    ***---***
    OMIT('***---***', _C60_)
    FieldRef                      &= WHAT(pQueue, FieldNo)
    ***---***
    FieldQ.IsGroup                 = ISGROUP(pQueue, FieldNo)
    FieldQ.IsNumeric               = TRUE
    IsDataUpper                    = FALSE
    !ST::Debug('ST::DebugQueue/LoadFieldQ: RECORDS(pQueue)='& RECORDS(pQueue))
    IF RECORDS(pQueue) > 0 AND pNoTouch <> 1
      DataLength                   = 0
      LOOP RecNo = 1 TO RECORDS(pQueue)
        GET(pQueue, RecNo)
        !ST::Debug('ST::DebugQueue/LoadFieldQ: RecNo='& RecNo &'; FieldRef='& FieldRef)
        IF FieldRef <> ''
          IF NOT NUMERIC(FieldRef)
            FieldQ.IsNumeric       = FALSE
          END
          SampleLength = LEN(CLIP(FieldRef))
          IF NOT FieldQ.IsNumeric AND UPPER(FieldRef) = FieldRef
            IsDataUpper            = TRUE
          END
          IF SampleLength > 25
            DataLength             = 25
          ELSIF DataLength < SampleLength
            DataLength             = SampleLength
          END
        END
      END
    ELSE
      IsDataUpper                  = TRUE
      FieldQ.IsNumeric             = FALSE
      DataLength                   = LEN(FieldRef)
    END
    DO CalculateColumnWidth
    ADD(FieldQ)
  END  
  !ST::Debug('ST::DebugQueue/LoadFieldQ/OUT')

CalculateColumnWidth          ROUTINE
  DATA
HeaderWidth SHORT,AUTO
DataWidth   SHORT,AUTO
  CODE
  HeaderWidth  = HeaderLength * WidthMultiplier:Narrow + UltVLB:HeaderOffset
  DataWidth    = DataLength * CHOOSE(~IsDataUpper, WidthMultiplier:Narrow, WidthMultiplier:Wide) + UltVLB:DataOffset
  FieldQ.Width = CHOOSE(DataWidth > HeaderWidth, DataWidth, HeaderWidth)
  SELF.Debug(FieldQ.Header &' - '& HeaderLength &' - '& DataLength &' - '& HeaderWidth &' - '& DataWidth &' - '& FieldQ.Width)  

!==============================================================================  
UltimateDebug.Message         PROCEDURE(STRING pDebugString)  

  CODE
  SELF.Debug(pDebugString)
                                               
!==============================================================================  
  
UltimateDebug.SetApplicationName  PROCEDURE(STRING pApplicationName,STRING pProgramExtension)    !,STRING

ApplicationName                     STRING(50)

  CODE
  CASE (pProgramExtension)
  OF ('EXE')
    ApplicationName = 'Application  <9>' & pApplicationName & '.EXE'
  OF ('DLL')
    ApplicationName = 'DLL          <9>' & pApplicationName & '.DLL'
  OF ('LIB')
    ApplicationName = 'Library      <9>' & pApplicationName & '.LIB'
  END   
    
  RETURN ApplicationName     
    
!==============================================================================  
  
UltimateDebug.SetShortApplicationName PROCEDURE(STRING pApplicationName,STRING pProgramExtension)    !,STRING

ApplicationName                         STRING(50)

  CODE
  CASE (pProgramExtension)
  OF ('EXE')
    ApplicationName = pApplicationName & '.EXE'
  OF ('DLL')
    ApplicationName = pApplicationName & '.DLL'
  OF ('LIB')
    ApplicationName = pApplicationName & '.LIB'
  END   
    
  RETURN ApplicationName    
!==============================================================================  
UltimateDebug.ShowProcedureInfo   PROCEDURE(STRING pProcedure,STRING pApplication,STRING pHelpID,STRING pCreated,STRING pModified,STRING pCompiled)

TheStats                            STRING(500)

Window                              WINDOW('Procedure Information'),AT(,,275,121),CENTER,GRAY
                                      GROUP('Procedure Information'),AT(3,8,190,102),USE(?GROUP1),BOXED
                                      END
                                      TEXT,AT(11,20,176,84),USE(TheStats),SKIP,TRN
                                      BUTTON('Send To Clipboard'),AT(198,61,72),USE(?BUTTONToClipboard)
                                      BUTTON('Send To Debug'),AT(198,78,72),USE(?BUTTONToDebug)
                                      BUTTON('Close'),AT(198,96,72),USE(?BUTTONClose)
                                    END


  CODE
  LOOP WHILE KEYBOARD() !Empty the keyboard buffer
    ASK                  !without processing keystrokes
  END
  SETKEYCODE(0)
  TheStats = ('Procedure:<9>' & CLIP(pProcedure) & '<13,10>' & |
      CLIP(pApplication) & '<13,10><13,10>' & |
      'Help ID    <9>' & CLIP(pHelpID) & '<13,10>' & |
      'Created  On<9>' & CLIP(pCreated) & '<13,10>' & |
      'Modified On<9>' & CLIP(pModified) & '<13,10>' & |
      'Compiled On<9>' & CLIP(pCompiled)) 
  OPEN(Window)
  ACCEPT
    CASE FIELD()
    OF ?BUTTONClose
      CASE EVENT()
      OF EVENT:Accepted
        BREAK
      END 
    OF ?BUTTONToClipboard
      CASE EVENT()
      OF EVENT:Accepted
        SETCLIPBOARD(TheStats)
      END
    OF ?BUTTONToDebug
      CASE EVENT()
      OF EVENT:Accepted
        Self.Debug(TheStats)
      END  
    END
      
  END
    
  LOOP WHILE KEYBOARD() !Empty the keyboard buffer
    ASK                  !without processing keystrokes
  END
  SETKEYCODE(0)
!==============================================================================  
UltimateDebug.FormatMessageList   PROCEDURE(STRING pMsg,*QUEUE pMsgQueue)   

!--------------------------------------
StartPos                            LONG(1)
Pos                                 LONG,AUTO
!--------------------------------------
  CODE
  IF pMsg
    LOOP WHILE StartPos
      Pos = INSTRING('|', pMsg, 1, StartPos)
      pMsgQueue = CHOOSE(Pos=0, pMsg[StartPos : LEN(pMsg)], pMsg[StartPos : Pos-1])
      ADD(pMsgQueue)
      ASSERT(ERRORCODE()=0)
      StartPos = Pos+1
    UNTIL Pos = 0
  END
  RETURN
!==============================================================================
!==============================================================================
UltimateDebug.Construct       PROCEDURE  

  CODE
    
  SELF.EventQ        &= NEW ST::DebugEventQueue
  SELF.IgnoreEventQ  &= NEW ST::DebugEventQueue
  SELF.CategoryQueue &= NEW DebugCategoryQueue
	
	
  SELF.SetPurgeTime(5*60*100)  !5 minutes 
  SELF.SetEventOffset 
    
  SELF.ShowAll        = TRUE
  SELF.ShowField      = FALSE
  SELF.ShowFocus      = FALSE
  SELF.ShowSelected   = FALSE
  SELF.ShowSelStart   = FALSE
  SELF.ShowSelEnd     = FALSE
  SELF.ShowKeyCode    = FALSE
  SELF.ShowError      = FALSE
  SELF.ShowThread     = FALSE
  SELF.ShowContents   = FALSE
  SELF.ShowScreenText = FALSE
  SELF.ShowAcceptAll  = FALSE
     
!    REGISTER(EVENT:AlertKey,ADDRESS(SELF.ShowProcedureInfo),ADDRESS(SELF))


  
UltimateDebug.SetEventOffSet  PROCEDURE
    
  code
  
  COMPILE('**++** _C60_Plus_',_C60_)
  SELF.EventOffset = 0A000h
  !  **++** _C60_Plus_
  OMIT   ('**--** _PRE_C6_',_C60_)
  SELF.EventOffset = 01400h
  !  **--** _PRE_C6_

  IF UPPER(SELF.GetEventDescr(EVENT:ACCEPTED)) <> 'EVENT:ACCEPTED' 
    self.HuntForOffSet                                               
  end
  

UltimateDebug.HuntForOffset   procedure
EventNum                        LONG
Pass                            BYTE
Lo                              LONG
Hi                              LONG
  code
  
  SELF.Debug('SELF.EventOffset is not correct, trying to find a correct value')

  SELF.EventOffset = CHOOSE(SELF.EventOffset = 01400h, 0A000h, 01400h)
  if UPPER(SELF.GetEventDescr(EVENT:ACCEPTED)) = 'EVENT:ACCEPTED' THEN RETURN END

  SELF.EventOffset = GETINI('Debuger','EventOffset', -1)
  CASE SELF.EventOffset
  OF -2; SELF.Debug('Stored value for EventOffset indicates no valid offset to be found, not searching')
  OF -1; SELF.Debug('SELF.EventOffset is not correct, searching for correct value')
  ELSE   ; IF UPPER(SELF.GetEventDescr(EVENT:ACCEPTED)) = 'EVENT:ACCEPTED'
    SELF.Debug('Using stored value for SELF.EventOffset')
    RETURN
  END
  END

  !The loops are split out to search more likely ranges first
  !for efficiency it makes more sense to check offsets incrementing by 100, searching for a result that starts with 'EVENT'
  LOOP Pass = 1 TO 4
    EXECUTE Pass
      BEGIN; Lo = 0A000h; Hi = 0AFFFh END
      BEGIN; Lo = 01000h; Hi = 01FFFh END
      BEGIN; Lo = 00000h; Hi = 00FFFh END
      BEGIN; Lo = 0B000h; Hi = 0FFFFh END
    END
    LOOP EventNum = Lo TO Hi
      SELF.EventOffset = EventNum
      IF UPPER(SELF.GetEventDescr(EVENT:ACCEPTED)) = 'EVENT:ACCEPTED'
        PUTINI('Debuger','EventOffset',SELF.EventOffset)
        RETURN
      END
    END
  END

  SELF.Debug('Could not find a working offset for .EventOffset')
  SELF.EventOffset = -2
  PUTINI('Debuger','EventOffset',SELF.EventOffset)


UltimateDebug.Destruct        PROCEDURE
  CODE
!	FREE(SELF.ControlQ)
!	DISPOSE(SELF.ControlQ)

  FREE(SELF.EventQ)
  DISPOSE(SELF.EventQ)

  FREE(SELF.IgnoreEventQ)
  DISPOSE(SELF.IgnoreEventQ)

  FREE(SELF.CategoryQueue)
  DISPOSE(SELF.CategoryQueue)

UltimateDebug.SetDebugEvent   PROCEDURE(SIGNED Event)
  CODE
  SELF.DebugEvent = Event


UltimateDebug.SetHotKey       PROCEDURE(UNSIGNED HotKey)
  CODE
  0{PROP:Alrt, 255} = HotKey
  SELF.HotKey = HotKey
  SELF.SetDebugEvent(EVENT:AlertKey)


UltimateDebug.SetPurgeTime    PROCEDURE(LONG PurgeTime)
  CODE
  IF PurgeTime <= 0
    SELF.PurgeStarTime = 0
  ELSE
    SELF.PurgeStarTime = SELF.CalcStarDate(0, PurgeTime)
  END


UltimateDebug.IgnoreEvent     PROCEDURE(SIGNED Event)
X                               LONG,AUTO
  CODE
  CLEAR(SELF.IgnoreEventQ)
  SELF.IgnoreEventQ.EventNo = Event
  ADD(SELF.IgnoreEventQ, SELF.IgnoreEventQ.EventNo)

  ! Purge existing logged events
  LOOP X = RECORDS(SELF.EventQ) TO 1 BY -1
    GET(SELF.EventQ, X)
    IF SELF.EventQ.EventNo = Event
      DELETE(SELF.EventQ)
    END
  END



UltimateDebug.TakeEvent       PROCEDURE
  CODE
!	? !UltimateDebug.Debug('UltimateDebug.TakeEvent: DebugEvent='& SELF.DebugEvent &'; Event='& EVENT() &'-'& SELF.GetEventName(EVENT()) &'; Keycode='& KEYCODE())
  CASE EVENT()
  OF 0
  OROF EVENT:Suspend
  OROF EVENT:Resume
!		?   !Self.Debug('...Ignore It')
    !Ignore it
  OF SELF.DebugEvent
!		?   !Self.Debug('...Debug Event  '& SELF.DebugEvent &'/'& EVENT:AlertKey &'  ' & KEYCODE() &'/'& SELF.HotKey)
    IF SELF.DebugEvent <> EVENT:AlertKey |
        OR KEYCODE() = SELF.HotKey
      SELF.Debug('')
    ELSE
      SELF.LogEvent
    END
  ELSE
!		?   !SELF.Debug('...Logger')
    IF SELF.DebugEvent <> EVENT:AlertKey     |
        OR EVENT()         <> EVENT:PreAlertKey  |
        OR KEYCODE()       <> SELF.HotKey
      SELF.LogEvent
    END
  END

UltimateDebug.LogEvent        PROCEDURE
  CODE
  SELF.IgnoreEventQ.EventNo = EVENT()
  GET(SELF.IgnoreEventQ, SELF.IgnoreEventQ.EventNo)
  IF ERRORCODE() <> 0
    CLEAR(SELF.EventQ)
    SELF.EventQ.Date      = FORMAT(TODAY(), @D10)
    SELF.EventQ.Time      = FORMAT(CLOCK(), @T6)
    SELF.EventQ.StarDate  = SELF.CalcStarDate()
    SELF.EventQ.EventNo   = EVENT()
    SELF.EventQ.EventName = SELF.GetEventName(EVENT())
    SELF.EventQ.FieldFeq  = FIELD()
!		SELF.EventQ.FieldName = SELF.GetControlName(FIELD()) TODO
    SELF.EventQ.Keycode   = KEYCODE()
    ADD(SELF.EventQ, SELF.EventQ.StarDate)
  END
  ! Purge old events
  LOOP WHILE SELF.PurgeStarTime <> 0 AND RECORDS(SELF.EventQ)
    GET(SELF.EventQ, 1)
    IF SELF.EventQ.StarDate > SELF.CalcStarDate() - SELF.PurgeStarTime THEN BREAK.
    DELETE(SELF.EventQ)
  END


UltimateDebug.CalcStarDate    PROCEDURE(<LONG D>,<LONG T>)!,REAL
  CODE
  IF OMITTED(D) THEN D = TODAY().
  IF OMITTED(T) THEN T = CLOCK().
  RETURN D + (T-1)/8640000


UltimateDebug.GetEventName    PROCEDURE(SIGNED Event)!,STRING
  CODE
  CASE Event

    ! Field-dependent events

  OF 01H;  RETURN 'Accepted'
  OF 02H;  RETURN 'NewSelection'
  OF 02H;  RETURN 'ScrollUp'
  OF 04H;  RETURN 'ScrollDown'
  OF 05H;  RETURN 'PageUp'
  OF 06H;  RETURN 'PageDown'
  OF 07H;  RETURN 'ScrollTop'
  OF 08H;  RETURN 'ScrollBottom'
  OF 09H;  RETURN 'Locate'

  OF 01H;  RETURN 'MouseDown'
  OF 0aH;  RETURN 'MouseUp'
  OF 0bH;  RETURN 'MouseIn'
  OF 0cH;  RETURN 'MouseOut'
  OF 0dH;  RETURN 'MouseMove'
  OF 0eH;  RETURN 'VBXevent'
  OF 0fH;  RETURN 'AlertKey'
  OF 10H;  RETURN 'PreAlertKey'
  OF 11H;  RETURN 'Dragging'
  OF 12H;  RETURN 'Drag'
  OF 13H;  RETURN 'Drop'
  OF 14H;  RETURN 'ScrollDrag'
  OF 15H;  RETURN 'TabChanging'
  OF 16H;  RETURN 'Expanding'
  OF 17H;  RETURN 'Contracting'
  OF 18H;  RETURN 'Expanded'
  OF 19H;  RETURN 'Contracted'
  OF 1AH;  RETURN 'Rejected'
  OF 1BH;  RETURN 'DroppingDown'
  OF 1CH;  RETURN 'DroppedDown'
  OF 1DH;  RETURN 'ScrollTrack'
  OF 1EH;  RETURN 'ColumnResize'

  OF 101H;  RETURN 'Selected'
  OF 102H;  RETURN 'Selecting'

    ! Field-independent events (FIELD() returns 0)

  OF 201H;  RETURN 'CloseWindow'
  OF 202H;  RETURN 'CloseDown'
  OF 203H;  RETURN 'OpenWindow'
  OF 204H;  RETURN 'OpenFailed'
  OF 205H;  RETURN 'LoseFocus'
  OF 206H;  RETURN 'GainFocus'

  OF 208H;  RETURN 'Suspend'
  OF 209H;  RETURN 'Resume'
  OF 20AH;  RETURN 'Notify'

  OF 20BH;  RETURN 'Timer'
  OF 20CH;  RETURN 'DDErequest'
  OF 20DH;  RETURN 'DDEadvise'
  OF 20EH;  RETURN 'DDEdata'
  OF 20FH;  RETURN 'DDEexecute'
  OF 210H;  RETURN 'DDEpoke'
  OF 211H;  RETURN 'DDEclosed'

  OF 220H;  RETURN 'Move'
  OF 221H;  RETURN 'Size'
  OF 222H;  RETURN 'Restore'
  OF 223H;  RETURN 'Maximize'
  OF 224H;  RETURN 'Iconize'
  OF 225H;  RETURN 'Completed'
  OF 230H;  RETURN 'Moved'
  OF 231H;  RETURN 'Sized'
  OF 232H;  RETURN 'Restored'
  OF 233H;  RETURN 'Maximized'
  OF 234H;  RETURN 'Iconized'
  OF 235H;  RETURN 'Docked'
  OF 236H;  RETURN 'Undocked'

  OF 240H;  RETURN 'BuildFile'
  OF 241H;  RETURN 'BuildKey'
  OF 242H;  RETURN 'BuildDone'

    ! User-definable events

  OF 3FFH;  RETURN 'DoResize'
  OF 400H;  RETURN 'User'
  END
  RETURN '???'
!==============================================================================	
!----------------------------------------------------------------------- 
! NOTES:
! Construct procedure executes automatically at the beginning of each procedure 
! Destruct procedure executes automatically at the end of each procedure
! Construct/Destruct Procedures are implicit under the hood but don't have to be declared in the class as such if there is no need.   
! It's ok to have them there for good measure, although some programmers only include them as needed.
! Normally some prefer Init() and Kill(),  but Destruct() can be handy to DISPOSE of stuff (to avoid mem leak)
!-----------------------------------------------------------------------                    
UltimateDebug.AddUserEvent    PROCEDURE(STRING argEventName,LONG argEventEquate)
  CODE
  IF ~SELF.UserEventNameQ &= NULL
    IF SELF.GetUserEvent(argEventEquate)
      SELF.UserEventNameQ.EventName    = argEventName
      PUT(SELF.UserEventNameQ)
    ELSE
      SELF.UserEventNameQ.EventEquate  = argEventEquate
      SELF.UserEventNameQ.EventName    = argEventName
      ADD(SELF.UserEventNameQ)
    END
  END

!-----------------------------------------------------------------------------------------!
UltimateDebug.GetUserEvent    PROCEDURE(LONG argEventEquate)!string
  CODE
  IF ~SELF.UserEventNameQ &= NULL
    SELF.UserEventNameQ.EventEquate  = argEventEquate
    GET(SELF.UserEventNameQ, SELF.UserEventNameQ.EventEquate)
    RETURN CHOOSE( ERRORCODE()=0, SELF.UserEventNameQ.EventName, '')
  ELSE
    RETURN ''
  END  
!-----------------------------------------------------------------------------------------!
UltimateDebug.GetEventDescr   PROCEDURE(LONG argEvent)!,string  !prototype set to default to -1
lcl:Retval                      LIKE(qtUserEventName.EventName)
lcl:EventNum                    UNSIGNED  
lcl:Position                    LONG

  CODE
  IF argEvent = -1
    argEvent = EVENT()
  END
  lcl:RetVal = SELF.GetUserEvent( argEvent )
  IF ~lcl:RetVal
    CASE argEvent
    OF Event:User                      ; lcl:RetVal = 'EVENT:User'
    OF Event:User + 1 TO Event:Last    ; lcl:RetVal = 'EVENT:User + '& argEvent - Event:User
    OF Event:APP                       ; lcl:RetVal = 'EVENT:App'
    OF Event:APP  + 1 TO Event:APP_LAST; lcl:RetVal = 'EVENT:App + ' & argEvent - Event:APP

    ELSE                                  
      IF SELF.EventOffset = -2   !indicates could not find a valid offset
        lcl:RetVal = 'EVENT['& argEvent &']'
      ELSE
        lcl:EventNum = argEvent + SELF.EventOffset  ! 1400h (pre c6) or A000h (c6) !EVENT:FIRST equate(01400h)/(0A000h)
        debugerNameMessage(lcl:RetVal, lcl:EventNum)
      END
    END
  END   
     
  RETURN lcl:RetVal   ![7:LEN(CLIP(lcl:RetVal))]

!-----------------------------------------------------------------------------------------!
UltimateDebug.GetFEQDescr     PROCEDURE(SIGNED argFEQ)!,string  !prototype set to default to -1

lcl:Retval                      CSTRING(40) !<--- some arbitrary length
lcl:FEQ                         SIGNED
szRef                           &CSTRING

  CODE
  lcl:FEQ     = CHOOSE(argFEQ = -1, FIELD(), argFEQ)
  COMPILE('** C55+ **',_C55_)
  lcl:RetVal  = debugerGetFieldName(lcl:FEQ)
  !END-COMPILE('** C55+ **',_C55_)
  OMIT('** C55+ **',_C55_)
  szRef      &= debugerGetFieldName(lcl:FEQ)
  lcl:RetVal  = szRef
  !END-OMIT('** C55+ **',_C55_)

  RETURN lcl:RetVal !CLIP(lcl:RetVal) 
  
!-----------------------------------------------------------------------------------------! 
!UltimateDebug.DebugEvent  
!Used to show Events as they are processed.
!Code by Mark Goldbert
!-----------------------------------------------------------------------------------------!
  
UltimateDebug.DebugEvent      PROCEDURE(<STRING pDebugProcedure>)

cs_DebugString                  string(600)
cl_Offset                       LONG
cb_DebugNoCR                    BYTE(0)
cs_Event                        STRING(4)
cs_Procedure                    STRING(20)
cl_ProcedureOffset              LONG


  CODE
    
  cl_Offset = 24
  cs_Procedure = pDebugProcedure
!  cs_DebugString = FORMAT(SELF.GetEventDescr(),@s30) & EVENT() 
  cs_Event = EVENT()
  cs_DebugString =  cs_Event & ' ' & SUB(SELF.GetEventDescr(),7,100)
  IF cs_Procedure
		
    cl_ProcedureOffset = LEN(CLIP(cs_DebugString)) + 2
    cl_Offset = 24 + cl_ProcedureOffset
    cs_DebugString = cs_Procedure[1:cl_ProcedureOffset] & cs_DebugString
		
  END
	
  if self.ShowField or self.ShowAll
    cs_DebugString = cs_DebugString[1:cl_Offset] & 'Field(' & SELF.GetFEQDescr() & ' = ' & FIELD()  &')'  
    cl_Offset += 34
  end
  
  if self.ShowFocus or self.ShowAll 
    cs_DebugString = cs_DebugString[1:cl_Offset] & 'Focus(' & SELF.GetFEQDescr(FOCUS()) & ' =' & FOCUS() & ')' 
    cl_Offset += 34
  end
  
  if self.ShowSelected or self.ShowAll
    cs_DebugString = cs_DebugString[1:cl_Offset] & 'Selected(' & SELF.GetFEQDescr(SELECTED()) & ' =' & SELECTED() & ')'
    cl_Offset += 34
  end
  
  if self.ShowSelStart or self.ShowAll
    cs_DebugString = cs_DebugString[1:cl_Offset] & 'SelStart(' & FOCUS(){prop:SelStart} & ')'
    cl_Offset += 14
  end
  
  if self.ShowSelEnd or self.ShowAll   
    cs_DebugString = cs_DebugString[1:cl_Offset] & 'SelEnd(' & FOCUS(){prop:SelEnd} & ')' 
    cl_Offset += 14
  end
  
  if self.ShowKeyCode or self.ShowAll 
    cs_DebugString = cs_DebugString[1:cl_Offset] & 'KeyCode(' & KEYCODE() & ')' 
    cl_Offset += 14
  end
  
  if self.ShowError or self.ShowAll  
    cs_DebugString = cs_DebugString[1:cl_Offset] & 'Error('& ERRORCODE() & ': ' & CLIP(ERROR()) & ')'  
    cl_Offset += 24
  end
  
  if self.ShowThread or self.ShowAll  
    cs_DebugString = cs_DebugString[1:cl_Offset] & 'Thread('& THREAD() & ')'  
    cl_Offset += 14
  end
    
  if self.ShowAcceptAll or self.ShowAll  
    cs_DebugString = cs_DebugString[1:cl_Offset] & 'AcceptAll('& 0{prop:AcceptAll} & ')' 
    cl_Offset += 14
  end  
    
  if self.ShowContents or self.ShowAll 
    cs_DebugString = cs_DebugString[1:cl_Offset] & 'Contents('& CONTENTS(FOCUS()) & ')'
    cl_Offset += 24
  end
  
  if self.ShowScreenText or self.ShowAll 
    cs_DebugString = cs_DebugString[1:cl_Offset] & 'ScreenText('& FOCUS(){prop:ScreenText} & ')'  
    cl_Offset += 50
  end       
  cs_DebugString = cs_DebugString[1:cl_Offset]
  cb_DebugNoCR = SELF.DebugNoCR
  SELF.DebugNoCR = TRUE
  SELF.DEBUG(clip(cs_DebugString),'',TRUE) 
  SELF.DebugNoCR = cb_DebugNoCR
	
	
UltimateDebug.GPF             PROCEDURE()

  CODE
  DebugBreak()
    