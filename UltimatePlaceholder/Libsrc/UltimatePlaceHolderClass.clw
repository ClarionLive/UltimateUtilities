                              MEMBER()

!
!--------------------------
!ClarionLive! Basic Class Template
!--------------------------

  INCLUDE('EQUATES.CLW')
  INCLUDE('UltimatePlaceholderClass.INC'),ONCE
  INCLUDE('UltimateDebug.inc'),ONCE


                              MAP
                              END

ud                            UltimateDebug

!==============================================================================
!==============================================================================
UltimatePlaceholderControlClass.InitWindow    PROCEDURE(SIGNED pEntryFEQ,<STRING pText>)

  CODE
        
  SELF.EntryFEQ = pEntryFEQ
  SELF.BoxFEQ = CREATE(0,CREATE:box)
        
  SELF.StringFEQ = CREATE(0,CREATE:string)
        
  SELF.StringFEQ{PROP:Follows} = SELF.BoxFEQ
  SELF.EntryFEQ{PROP:Follows} = SELF.StringFEQ
        
  IF SELF.EntryFEQ{PROP:Color} <> COLOR:NONE
    SELF.BoxFEQ{PROP:Fill} =  SELF.EntryFEQ{PROP:Color,1}
  ELSE
    SELF.BoxFEQ{PROP:Fill} =  COLOR:Window
  END
  SELF.BoxFEQ{PROP:Color} = COLOR:GRAYTEXT  !COLOR:Gray
        
  SELF.EntryFEQ{PROP:Imm} = TRUE
  SELF.EntryFEQ{PROP:Trn} = TRUE
        
  SELF.StringFEQ{PROP:FontColor} = COLOR:Silver
  SELF.StringFEQ{PROP:Trn} = TRUE
  SELF.StringFEQ{PROP:Left} = TRUE
  SELF.StringFEQ{PROP:LeftOffSet} = 0
        
  SELF.Text = pText
  SELF.BoxFEQ{PROP:Hide} = FALSE
  SELF.StringFEQ{PROP:Hide} = FALSE
  SELF.Refresh()
        
  RETURN


!==============================================================================
UltimatePlaceholderControlClass.Refresh   PROCEDURE()

x                                           SIGNED
y                                           SIGNED
w                                           SIGNED
h                                           SIGNED


  CODE

  GETPOSITION(SELF.EntryFEQ,x,y,w,h)
        
  SETPOSITION(SELF.BoxFEQ,x,y,w,h)
  SETPOSITION(SELF.StringFEQ,x+2,y+1,w,h)

  IF SELF.BoxFEQ{PROP:Hide} <> SELF.EntryFEQ{PROP:Hide}
    SELF.BoxFEQ{PROP:Hide} = SELF.EntryFEQ{PROP:Hide}
  END
        
  IF SELF.EntryFEQ{PROP:ScreenText} = ''
    IF SELF.StringFEQ{PROP:Hide} <> SELF.EntryFEQ{PROP:Hide}
      SELF.StringFEQ{PROP:Hide} = SELF.EntryFEQ{PROP:Hide}
    END
  ELSE
    IF SELF.StringFEQ{PROP:Hide} <> TRUE
      SELF.StringFEQ{PROP:Hide} = TRUE
    END
  END
        
  IF SELF.Text
    SELF.StringFEQ{PROP:Text} = SELF.Text
  ELSIF SELF.EntryFEQ{PROP:Msg}
    SELF.StringFEQ{PROP:Text} = SELF.EntryFEQ{PROP:Msg}
  ELSIF SELF.EntryFEQ{PROP:Tip}
    SELF.StringFEQ{PROP:Text} = SELF.EntryFEQ{PROP:Tip}
  ELSE
    SELF.StringFEQ{PROP:Text} = ''
  END
        
  RETURN

        
!==============================================================================
UltimatePlaceholderControlClass.TakeEvent PROCEDURE()

  CODE
        
  IF FIELD() = SELF.EntryFEQ AND EVENT() = EVENT:NewSelection
    SELF.Refresh()
               
  END
        
  RETURN 

!==============================================================================
!==============================================================================

UltimatePlaceholderWindowClass.Construct  PROCEDURE
  CODE
  SELF.ControlQueue &= NEW UltimatePlaceholderControlQueueType

UltimatePlaceholderWindowClass.Destruct   PROCEDURE
  CODE
  LOOP WHILE RECORDS(SELF.ControlQueue)
    GET(SELF.ControlQueue, 1)
    DISPOSE(SELF.ControlQueue.ControlObject)
    DELETE(SELF.ControlQueue)
  END
  DISPOSE(SELF.ControlQueue)

UltimatePlaceholderWindowClass.AddControl PROCEDURE(SIGNED pEntryFEQ,<STRING pText>) !,EXTENDS
  CODE
  CLEAR(SELF.ControlQueue)
  SELF.ControlQueue.ControlObject &= NEW UltimatePlaceHolderControlClass
  ADD(SELF.COntrolQueue)
  SELF.ControlQueue.ControlObject.InitWindow(pEntryFEQ, pText)

UltimatePlaceholderWindowClass.Refresh    PROCEDURE()
X                                           LONG
  CODE
  LOOP X = 1 TO RECORDS(SELF.ControlQueue)
    GET(SELF.ControlQueue, X)
    SELF.ControlQueue.ControlObject.Refresh()
  END

UltimatePlaceholderWindowClass.TakeEvent  PROCEDURE()
X                                           LONG
  CODE
  LOOP X = 1 TO RECORDS(SELF.ControlQueue)
    GET(SELF.ControlQueue, X)
    SELF.ControlQueue.ControlObject.TakeEvent()
  END
