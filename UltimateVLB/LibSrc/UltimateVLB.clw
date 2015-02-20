                              MEMBER

  INCLUDE('UltimateVLB.inc'),ONCE
  INCLUDE('Equates.clw'),ONCE
  INCLUDE('Errors.clw'),ONCE
  INCLUDE('Keycodes.clw'),ONCE

ELEMENT:DisplayValue          EQUATE(1)

                              MAP
                                MODULE('Windows API')
WinAPI:GetSysColor                PROCEDURE(SIGNED nIndex),LONG,PASCAL,NAME('GetSysColor')
                                END
                                INCLUDE('CWUtil.inc')
                                INCLUDE('STDebug.inc')
                              END

!==============================================================================
!==============================================================================
UltVLB:ColumnClass.Construct  PROCEDURE
  CODE
  SELF.Width          = 100
  SELF.Justification  = 'L'
  SELF.Offset         = UltVLB:DataOffset
  SELF.HJustification = 'L'
  SELF.HOffset        = UltVLB:HeaderOffset
  
!==============================================================================
UltVLB:ColumnClass.FormatColumn   PROCEDURE(SIGNED ListFEQ,SHORT ColumnNo)
  CODE
  ListFEQ{PROPLIST:Width  , ColumnNo} = SELF.Width
  ListFEQ{PROPLIST:Header , ColumnNo} = SELF.Header
  ListFEQ{PROPLIST:Picture, ColumnNo} = SELF.Picture
  CASE SELF.Justification
    ;OF 'D';  !No-op
    ;OF 'L';  ListFEQ{PROPLIST:Left  , ColumnNo} = TRUE;  ListFEQ{PROPLIST:LeftOffset  , ColumnNo} = SELF.Offset
    ;OF 'R';  ListFEQ{PROPLIST:Right , ColumnNo} = TRUE;  ListFEQ{PROPLIST:RightOffset , ColumnNo} = SELF.Offset
    ;OF 'C';  ListFEQ{PROPLIST:Center, ColumnNo} = TRUE;  ListFEQ{PROPLIST:CenterOffset, ColumnNo} = SELF.Offset
  END
  CASE SELF.HJustification
    ;OF 'D';  !No-op
    ;OF 'L';  ListFEQ{PROPLIST:HeaderLeft  , ColumnNo} = TRUE;  ListFEQ{PROPLIST:HeaderLeftOffset  , ColumnNo} = SELF.HOffset
    ;OF 'R';  ListFEQ{PROPLIST:HeaderRight , ColumnNo} = TRUE;  ListFEQ{PROPLIST:HeaderRightOffset , ColumnNo} = SELF.HOffset
    ;OF 'C';  ListFEQ{PROPLIST:HeaderCenter, ColumnNo} = TRUE;  ListFEQ{PROPLIST:HeaderCenterOffset, ColumnNo} = SELF.HOffset
  END
  ListFEQ{PROPLIST:Color      , ColumnNo} = SELF.HasColor
  ListFEQ{PROPLIST:RightBorder, ColumnNo} = TRUE
  ListFEQ{PROPLIST:Resize     , ColumnNo} = TRUE

!==============================================================================
UltVLB:ColumnClass.GetElementCount       PROCEDURE!,SHORT
Elements                        SHORT(0)
  CODE
  ;                     Elements += 1
  IF SELF.HasColor THEN Elements += 4.
  IF SELF.HasIcon  THEN Elements += 1.
  IF SELF.HasStyle THEN Elements += 1.
  IF SELF.HasTree  THEN Elements += 1.
  RETURN Elements

!==============================================================================
UltVLB:ColumnClass.GetElementLONG PROCEDURE(SHORT Elem)!,LONG
  CODE
  RETURN COLOR:NONE  !TODO
  
!==============================================================================
UltVLB:ColumnClass.GetElementSTRING   PROCEDURE(SHORT Elem)!,STRING
  CODE
  IF Elem = ELEMENT:DisplayValue
    RETURN SELF.GetValue()
  ELSE
    RETURN SELF.GetElementLONG(Elem)
  END
  
!==============================================================================
UltVLB:ColumnClass.GetValue   PROCEDURE!,STRING
  CODE
  IF NOT SELF.FieldRef &= NULL
    RETURN SELF.FieldRef
  ELSE
    RETURN ''
  END

!==============================================================================
UltVLB:ColumnClass.IsElementNormalBG  PROCEDURE(BYTE Elem)!,BOOL
  CODE
  RETURN CHOOSE(Elem = 3)  !TODO
    
!==============================================================================
!==============================================================================
UltVLB:ColumnClassForNumber.Construct PROCEDURE
  CODE
  SELF.Width          = 40
  SELF.Justification  = 'R'
  SELF.Offset         = UltVLB:DataOffset
  SELF.HJustification = 'C'
  SELF.HOffset        = 0

!==============================================================================
!==============================================================================
UltimateVLB.Construct           PROCEDURE
  CODE
  SELF.ColumnQueue &= NEW UltVLB:ColumnQueue

!==============================================================================
UltimateVLB.Destruct            PROCEDURE
  CODE
  LOOP WHILE RECORDS(SELF.ColumnQueue)
    GET(SELF.ColumnQueue, 1)
    IF SELF.ColumnQueue.DisposeObject
      DISPOSE(SELF.ColumnQueue.Column)
    END
    DELETE(SELF.ColumnQueue)
  END
  DISPOSE(SELF.ColumnQueue)

!==============================================================================
UltimateVLB.Init              PROCEDURE(SIGNED FEQ,<QUEUE ListQueue>)
                              MAP
AssignVLB                       PROCEDURE
AssignListAttributes            PROCEDURE
DeriveStripeColorFromBarColor   PROCEDURE
FormatColumns                   PROCEDURE
                              END
  CODE
  SELF.FEQ                = FEQ
  SELF.ListQueue         &= ListQueue
  SELF.OriginalListHeight = feq{PROP:Height}
  SELF.MeasureList
  DeriveStripeColorFromBarColor
  AssignListAttributes
  FormatColumns
  AssignVLB
  
!--------------------------------------
AssignVLB                     PROCEDURE
  CODE
  SELF.FEQ{PROP:VLBval } = ADDRESS(SELF)           !Must assign this first
  SELF.FEQ{PROP:VLBproc} = ADDRESS(SELF.VLBproc)    ! then this

!--------------------------------------
AssignListAttributes          PROCEDURE
  CODE
  SELF.FEQ{PROP:VScroll} = TRUE

!--------------------------------------
DeriveStripeColorFromBarColor PROCEDURE
H                               REAL
S                               REAL
L                               REAL
COLOR_HIGHLIGHT                 EQUATE(13)
  CODE
  SELF.StripeColor = feq{PROP:SelectedFillColor}
  IF SELF.StripeColor = COLOR:NONE
    SELF.StripeColor = WinAPI:GetSysColor(COLOR_HIGHLIGHT)
  END
  ColorToHSL(SELF.StripeColor, H, S, L)
  HSLToColor(H, S, (L+5)/6, SELF.StripeColor)

!--------------------------------------
FormatColumns                 PROCEDURE
                              MAP
CreateFormatStringToSignalNumberOfColumns   PROCEDURE
                              END
C                               BYTE,AUTO
  CODE
  CreateFormatStringToSignalNumberOfColumns
  LOOP C = 1 TO RECORDS(SELF.ColumnQueue)
    GET(SELF.ColumnQueue, C)
    SELF.ColumnQueue.Column.FormatColumn(SELF.FEQ, C)
  END
  
!..................
CreateFormatStringToSignalNumberOfColumns PROCEDURE
F                                           CSTRING(10000)
  CODE
  LOOP C = 1 TO RECORDS(SELF.ColumnQueue)
    F = F & '1L'
  END
  feq{PROP:Format} = F
  
!==============================================================================
UltimateVLB.AddColumn         PROCEDURE(UltVLB:ColumnClass C,<BOOL DisposeObject>)
  CODE
  C.HasColor = TRUE  !TODO
  CLEAR(SELF.ColumnQueue)
  SELF.ColumnQueue.Column       &= C
  SELF.ColumnQueue.DisposeObject = DisposeObject
  SELF.ColumnQueue.ElementCount  = C.GetElementCount()
  ADD(SELF.ColumnQueue)

!==============================================================================
UltimateVLB.GetColumnValue    PROCEDURE(LONG Row,SHORT Col)!,STRING
  CODE
  RETURN ''

!==============================================================================
UltimateVLB.FetchRow          PROCEDURE(LONG Row)!,BYTE
  CODE
  IF NOT SELF.ListQueue &= NULL
    GET(SELF.ListQueue, Row)
    RETURN CHOOSE(ERRORCODE()=NoError, Level:Benign, Level:Notify)
  ELSE
    RETURN Level:Notify
  END

!==============================================================================
UltimateVLB.GetElement        PROCEDURE(LONG Row,SHORT Elem)!,STRING
Column                          SHORT(0)
ElementValue                    LONG
  CODE
  LOOP UNTIL Column = RECORDS(SELF.ColumnQueue)
    Column += 1
    GET(SELF.ColumnQueue, Column)
    IF Elem <= SELF.ColumnQueue.ElementCount
      IF SELF.FetchRow(Row) = Level:Benign
        IF Elem = ELEMENT:DisplayValue
          RETURN SELF.ColumnQueue.Column.GetValue()
        ELSE
          !ST::Debug('Elem='& Elem &'; Value='& SELF.ColumnQueue.Column.GetElementLONG(Elem) &'; IsNormalBG='& SELF.ColumnQueue.Column.IsElementNormalBG(Elem) &'; StripeColor='& SELF.GetStripeColor(Row) &'/'& SELF.StripeColor)
          ElementValue = SELF.ColumnQueue.Column.GetElementLONG(Elem)
          IF ElementValue = COLOR:NONE |
              AND SELF.ColumnQueue.Column.IsElementNormalBG(Elem)
            RETURN SELF.GetStripeColor(Row)
          ELSE
            RETURN ElementValue
          END
        END
      ELSE
        BREAK
      END
    ELSE
      Elem -= SELF.ColumnQueue.ElementCount
    END
  END
  RETURN ''

!==============================================================================
UltimateVLB.GetElementCount   PROCEDURE!,SHORT
Col                             SHORT,AUTO
  CODE
  IF SELF.ElementCount = 0
    LOOP Col = 1 TO RECORDS(SELF.ColumnQueue)
      GET(SELF.ColumnQueue, Col)
      SELF.ElementCount += SELF.ColumnQueue.Column.GetElementCount()
    END
  END
  RETURN SELF.ElementCount
  
!==============================================================================
UltimateVLB.GetStripeColor    PROCEDURE(LONG Row)!,LONG
  CODE
  RETURN CHOOSE(BAND(Row,1), COLOR:NONE, SELF.StripeColor)
  
!==============================================================================
UltimateVLB.HasDataChanged    PROCEDURE!,BOOL
NewCHANGES                      LONG
  CODE
  IF SELF.ListQueue &= NULL
    RETURN FALSE
  ELSE
    NewCHANGES = CHANGES(SELF.ListQueue)
    IF NewCHANGES <> SELF.OldCHANGES
      SELF.OldCHANGES = NewCHANGES
      RETURN TRUE
    ELSE
      RETURN FALSE
    END
  END
  
!==============================================================================
UltimateVLB.MeasureList       PROCEDURE
  CODE
  SELF.ListItems       = SELF.FEQ{PROP:Items}
  SELF.FEQ{PROP:Items} = SELF.ListItems
  
!==============================================================================
UltimateVLB.Records           PROCEDURE(BYTE ReturnAtLeastOnePage=1)!,LONG
R                               LONG(0)
  CODE
  IF NOT SELF.ListQueue &= NULL
    R = RECORDS(SELF.ListQueue)
!    IF ReturnAtLeastOnePage AND R < SELF.ListItems
!      R = SELF.ListItems.
!    END
  END
  RETURN R
  
!==============================================================================
UltimateVLB.VLBproc           PROCEDURE(LONG Row, SHORT Elem)  !Required first parameter is implied
VLB:RowParm:RecordCount         EQUATE(-1)
VLB:RowParm:ElementCount        EQUATE(-2)
VLB:RowParm:HasChanges          EQUATE(-3)

  CODE
  CASE Row
    ;OF VLB:RowParm:RecordCount ;  ST::Debug('VLB:RecordCount'); RETURN SELF.Records()
    ;OF VLB:RowParm:ElementCount;  ST::Debug('VLB:GetElems'   ); RETURN SELF.GetElementCount()
    ;OF VLB:RowParm:HasChanges  ;  ST::Debug('VLB:HasChanged' ); RETURN SELF.HasDataChanged()
    ;ELSE                       ;  ST::Debug('VLB:GetElem['& Row &':'& Elem &']'); RETURN SELF.GetElement(Row, Elem)
  END

!==============================================================================
