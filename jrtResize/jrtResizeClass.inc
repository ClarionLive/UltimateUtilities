!-------------------------------------------------------------------------------
! Copyright Joe Tailleur (2014)
! Free to use - please submit any questions / requests to joe.tailleur@gmail.com
!-------------------------------------------------------------------------------

! Do not hide any of your columns initially.  
! That way you always have the columns default size available 
! 
! If you are hiding and unhiding your columns, use the "ResetColumnSizes" method to reset all columns 
! and then use the "HideColumn(Column,TRUE)" method to hide it if you need to.

! Example:
!  jrtResize.ResetColumnSizes()     ! Reset all column sizes to their design size
!  jrtResize.HideColumn(1,TRUE)     ! Sets column 1 to 0 size (hidden)
!  jrtResize.ResizeList(TRUE)       ! Force the columns in the list to resize

!--------------------------------------------
! Define the Queue used inside the class
!--------------------------------------------
ColumnSizesQType  QUEUE,TYPE
ColumnNumber        LONG
ColumnSize          LONG
ColumnGroupSize     LONG
GroupNumber         LONG
       END


!--------------------------------------------
! Class Definition
!--------------------------------------------
jrtResizeClass CLASS,TYPE,MODULE('jrtResizeClass.clw'),LINK('jrtResizeClass.clw',1),DLL(0)
ColumnNumber          LONG
GroupNumber           LONG
NewGroupNumber        LONG
OrginalColumnTotalWidth REAL
CurrentColumnTotalWidth REAL
WidthChange             REAL
LastWidthChange         REAL
CurrentWidth            LONG
OriginalWidth           LONG
NewColumnSize           LONG
NewGroupSize            LONG
_ListFEQ                LONG
ColumnSizes     &ColumnSizesQType
Construct             PROCEDURE()
Destruct              PROCEDURE()
Init                  PROCEDURE(LONG pFEQ),VIRTUAL
ResetColumnSizes      PROCEDURE,VIRTUAL
ResizeList            PROCEDURE (<BYTE pForce>),VIRTUAL
ResizeColumns         PROCEDURE (<BYTE pForce>),VIRTUAL
ResizeColumn          PROCEDURE (LONG pColumnNumber,LONG pColumnSize),VIRTUAL
ResizeGroup           PROCEDURE (LONG pColumnNumber,LONG pGroupSize),VIRTUAL
CalculateWidthChange  PROCEDURE (),VIRTUAL
HideColumn            PROCEDURE (LONG pColumnNumber,BYTE pHide=1),VIRTUAL
    END