!ABCIncludeFile
               
UltVLB:Justify:Default        EQUATE('D')
UltVLB:Justify:Left           EQUATE('L')
UltVLB:Justify:Right          EQUATE('R')
UltVLB:Justify:Center         EQUATE('C')
                                      
UltVLB:Offset:Data            EQUATE(2)
UltVLB:Offset:Header          EQUATE(1)

UltVLB:Width:String           EQUATE(100)
UltVLB:Width:Number           EQUATE(40)

!                              ITEMIZE(1)
!UltVLB:QColor:NormalFG          EQUATE
!UltVLB:QColor:NormalBG          EQUATE
!UltVLB:QColor:SelectedFG        EQUATE
!UltVLB:QColor:SelectedBG        EQUATE
!                              END

UltVLB:ColumnGroup            GROUP,TYPE
FieldNo                         LONG        !Queue field number
FieldRef                        ANY         !Queue field reference
!FieldName                       STRING(50) !Queue field name (for sorting)
Header                          STRING(50) !Saved Header text, also used for descriptive field name
!GroupHeader                     STRING(50) !Saved Group Header text    !MJH 2009/10/16
Width                           SHORT       !Column Width
Picture                         STRING(30) !Column Picture
Justification                   STRING(1)   !Column Justification: L/R/C/D
Offset                          SHORT       !Column Justification Offset
HJustification                  STRING(1)   !Header Justification: L/R/C/D
HOffset                         SHORT       !Header Justification Offset
IsFixed                         BOOL
IsResizable                     BOOL
HasColor                        BOOL
HasIcon                         BOOL
HasRightBorder                  BOOL
HasStyle                        BOOL
HasTree                         BOOL
                              END

UltVLB:ColumnClass            CLASS(UltVLB:ColumnGroup),TYPE,MODULE('UltimateVLB.clw'),LINK('UltimateVLB.clw')!,_ABCLinkMode_),DLL(_ABCDllMode_)
Construct                       PROCEDURE
FormatColumn                    PROCEDURE(SIGNED ListFEQ,SHORT ColumnNo)
GetElementCount                 PROCEDURE,SHORT,VIRTUAL
GetElementLONG                  PROCEDURE(SHORT Elem),LONG
GetElementSTRING                PROCEDURE(SHORT Elem),STRING
GetValue                        PROCEDURE,STRING,VIRTUAL
IsElementNormalBG               PROCEDURE(BYTE Elem),BOOL
                              END

UltVLB:ColumnClassForNumber   CLASS(UltVLB:ColumnClass),TYPE,MODULE('UltimateVLB.clw'),LINK('UltimateVLB.clw')!,_ABCLinkMode_),DLL(_ABCDllMode_)
Construct                       PROCEDURE
                              END

UltVLB:ColumnQueue            QUEUE,TYPE
Column                          &UltVLB:ColumnClass
DisposeObject                   BOOL
ElementCount                    BYTE
                              END

UltimateVLB                   CLASS,TYPE,MODULE('UltimateVLB.clw'),LINK('UltimateVLB.clw')!,_ABCLinkMode_),DLL(_ABCDllMode_)
Construct                       PROCEDURE
Destruct                        PROCEDURE
ColumnQueue                     &UltVLB:ColumnQueue
ElementCount                    BYTE,PROTECTED
FEQ                             SIGNED
ListItems                       LONG,PROTECTED
OldCHANGES                      LONG,PROTECTED
OriginalListHeight              SHORT,PROTECTED
ListQueue                       &QUEUE,PROTECTED  !Optional QUEUE
StripeColor                     LONG
Init                            PROCEDURE(SIGNED FEQ,<QUEUE ListQueue>)
AddColumn                       PROCEDURE(UltVLB:ColumnClass C,<BOOL DisposeObject>)
FetchRow                        PROCEDURE(LONG Row),BYTE,PROC,VIRTUAL
GetColumnValue                  PROCEDURE(LONG Row,SHORT Col),STRING,VIRTUAL
GetElement                      PROCEDURE(LONG Row,SHORT Elem),STRING,VIRTUAL
GetElementCount                 PROCEDURE,LONG,VIRTUAL
GetStripeColor                  PROCEDURE(LONG Row),LONG,VIRTUAL
HasDataChanged                  PROCEDURE,BOOL,VIRTUAL
MeasureList                     PROCEDURE,VIRTUAL
Records                         PROCEDURE(BYTE ReturnAtLeastOnePage=1),LONG,VIRTUAL
VLBproc                         PROCEDURE(LONG Row, SHORT Column),STRING,PROTECTED,VIRTUAL  !Required first parameter is implicit in a CLASS method
                              END
