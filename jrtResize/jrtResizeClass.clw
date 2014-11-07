!-------------------------------------------------------------------------------
! Copyright Joe Tailleur (2014)
! Free to use - please submit any questions / requests to joe.tailleur@gmail.com
!-------------------------------------------------------------------------------

    MEMBER()
    MAP
    module('')
	   jrtOutputDebugString(*CString),raw,pascal,Name('OutputDebugStringA')
    end
    jrtdbg(String pDebugString)
    END

    INCLUDE('jrtResizeClass.inc')

jrtResizeClass.Construct PROCEDURE
    CODE
    SELF.ColumnSizes &= NEW ColumnSizesQType

jrtResizeClass.Destruct  PROCEDURE
    CODE
    FREE(SELF.ColumnSizes)
    DISPOSE(SELF.ColumnSizes)


!---------------------------------------------------------------------
! Saves the columns sizes to the Queue as they were originally defined
! Make sure to put this call at  ABC Objects - Window Manager - Init - Priority 8060
! jrtResize template should do this for you
!---------------------------------------------------------------------
jrtResizeClass.Init   PROCEDURE (LONG pFEQ)
    CODE
    jrtdbg('Save Column Sizes')
    SELF._ListFeQ = pFEQ

    DO FreeBrowseSizeQueues
    DO SaveOriginalBrowseSize
    DO SaveColumnSizes

    RETURN

    
FreeBrowseSizeQueues    ROUTINE    
    FREE(SELF.ColumnSizes)
    CLEAR(SELF.ColumnSizes)

    
SaveOriginalBrowseSize  ROUTINE
    SELF.OriginalWidth = SELF._ListFeQ{PROP:Width}
    jrtdbg('Original Width: ' & SELF.OriginalWidth)

    
SaveColumnSizes      ROUTINE
    SELF.ColumnNumber = 0 
    LOOP
        SELF.ColumnNumber += 1
        IF SELF._ListFEQ{PROPLIST:Exists, SELF.ColumnNumber} = FALSE
            BREAK
        ELSE
            SELF.ColumnSizes.ColumnNumber    = SELF.ColumnNumber
            SELF.ColumnSizes.ColumnSize      = SELF._ListFEQ{PROPLIST:width, SELF.ColumnNumber}
            SELF.ColumnSizes.ColumnGroupSize = SELF._ListFEQ{PROPLIST:width + PROPLIST:Group, SELF.ColumnNumber}
            IF SELF.ColumnSizes.ColumnGroupSize < SELF.ColumnSizes.ColumnSize
                SELF.ColumnSizes.ColumnGroupSize = SELF.ColumnSizes.ColumnSize
            END
            SELF.ColumnSizes.GroupNumber = SELF._ListFEQ{PROPLIST:GroupNo,SELF.ColumnNumber}
            jrtdbg('Save Column Number: ' & SELF.ColumnNumber & ' - Column Size: ' & SELF.ColumnSizes.ColumnSize |
                & ' Group Number: ' & SELF.ColumnSizes.GroupNumber & ' - Group Size: ' & SELF.ColumnSizes.ColumnGroupSize)
            ADD(SELF.ColumnSizes)
            CLEAR(SELF.ColumnSizes)
        END
    END

    SORT(SELF.ColumnSizes, SELF.ColumnSizes.ColumnNumber)

    
!--------------------------------------------------------
jrtResizeClass.ResizeColumns PROCEDURE (<BYTE pForce>)
    CODE
    jrtdbg('Resize Columns in the list')

    SELF.CalculateWidthChange()
    IF SELF.LastWidthChange <> SELF.WidthChange OR pForce = TRUE
        DO AdjustForMissingColumn
        DO ResizeColumn
        SELF.LastWidthChange = SELF.WidthChange
    END

    RETURN

ResizeColumn    ROUTINE
    SELF.ColumnNumber = 0 
    LOOP        
        SELF.ColumnNumber += 1
        IF SELF._ListFEQ{PROPLIST:Exists, SELF.ColumnNumber} = FALSE
            BREAK
        ELSE
            SELF.ColumnSizes.ColumnNumber = SELF.ColumnNumber
            GET(SELF.ColumnSizes, SELF.ColumnSizes.ColumnNumber)
            IF ERRORCODE() = FALSE
                IF SELF._ListFEQ{PROPLIST:width, SELF.ColumnNumber} > 0
                    SELF.NewColumnSize = (SELF.ColumnSizes.ColumnSize * SELF.WidthChange)
                    SELF.NewGroupSize  = (SELF.ColumnSizes.ColumnGroupSize * SELF.WidthChange)
                    SELF._ListFEQ{PROPLIST:width, SELF.ColumnNumber} = SELF.NewColumnSize
                    SELF._ListFEQ{PROPLIST:width + PROPLIST:Group, SELF.ColumnNumber} = SELF.NewGroupSize
                END
            END
        END
    END

AdjustForMissingColumn ROUTINE
    jrtdbg('Adjust for missing columns')
    SELF.CurrentColumnTotalWidth = 0
    SELF.OrginalColumnTotalWidth = 0
    SELF.ColumnNumber = 0 
    LOOP        
        SELF.ColumnNumber += 1
        IF SELF._ListFEQ{PROPLIST:Exists, SELF.ColumnNumber} = FALSE
            BREAK
        ELSE
            SELF.ColumnSizes.ColumnNumber = SELF.ColumnNumber
            GET(SELF.ColumnSizes, SELF.ColumnSizes.ColumnNumber)
            IF ERRORCODE() = FALSE
                IF SELF._ListFEQ{PROPLIST:width, SELF.ColumnNumber} > 0
                    SELF.CurrentColumnTotalWidth += SELF.ColumnSizes.ColumnSize + 2
                    SELF.OrginalColumnTotalWidth += SELF.ColumnSizes.ColumnSize
                ELSE
                    SELF.OrginalColumnTotalWidth += SELF.ColumnSizes.ColumnSize
                END
            END
        END
    END
    SELF.WidthChange = (SELF.CurrentWidth / SELF.CurrentColumnTotalWidth)

    jrtdbg('Original Column Widths: ' & SELF.OrginalColumnTotalWidth)
    jrtdbg('Current Column Widths: ' & SELF.CurrentColumnTotalWidth)
    jrtdbg('Current List Width: ' & SELF.CurrentWidth)
    jrtdbg('New Width Change: ' & SELF.WidthChange)


!--------------------------------------------------------
jrtResizeClass.ResizeList   PROCEDURE (<BYTE pForce>)
    CODE
    jrtdbg('Resize Columns in the list')

    SELF.CalculateWidthChange()
    IF SELF.LastWidthChange <> SELF.WidthChange OR pForce = TRUE
        DO ResizeColumn
        SELF.LastWidthChange = SELF.WidthChange
    END

    RETURN

ResizeColumn ROUTINE
    SELF.ColumnNumber = 0 
    LOOP        
        SELF.ColumnNumber += 1
        IF SELF._ListFEQ{PROPLIST:Exists, SELF.ColumnNumber} = FALSE
            BREAK
        ELSE
            SELF.ColumnSizes.ColumnNumber = SELF.ColumnNumber
            GET(SELF.ColumnSizes, SELF.ColumnSizes.ColumnNumber)
            IF ERRORCODE() = FALSE
                IF SELF._ListFEQ{PROPLIST:width, SELF.ColumnNumber} > 0
                    SELF.NewColumnSize = (SELF.ColumnSizes.ColumnSize * SELF.WidthChange)
                    SELF.NewGroupSize  = (SELF.ColumnSizes.ColumnGroupSize * SELF.WidthChange)
                    SELF._ListFEQ{PROPLIST:width, SELF.ColumnNumber} = SELF.NewColumnSize
                    SELF._ListFEQ{PROPLIST:width + PROPLIST:Group, SELF.ColumnNumber} = SELF.NewGroupSize
                END
            END
        END
    END

!---------------------------------------------------------------------------
jrtResizeClass.CalculateWidthChange PROCEDURE
    CODE
    SELF.CurrentWidth = SELF._ListFEQ{PROP:Width}    
    SELF.WidthChange = (SELF.CurrentWidth / SELF.OriginalWidth)
    jrtdbg('Width Change: ' & SELF.WidthChange)


!---------------------------------------------------------------------------
jrtResizeClass.ResizeColumn  PROCEDURE (LONG pColumnNumber,LONG pColumnSize)
    CODE
    jrtdbg('Resize a single column size')

    SELF.CalculateWidthChange()
    IF SELF._ListFEQ{PROPLIST:Exists, pColumnNumber} = TRUE
        SELF.ColumnSizes.ColumnNumber = pColumnNumber
        GET(SELF.ColumnSizes, SELF.ColumnSizes.ColumnNumber)
        IF ERRORCODE() = FALSE
            ! Save the new column size into the queue
            ! Not yet done...
            ! --------------------------------------------------------------------------------------------
            ! Resize the column and group for the new column size plus the current width change
            SELF._ListFEQ{PROPLIST:width + PROPLIST:Group, pColumnNumber} = pColumnSize * SELF.WidthChange
            SELF._ListFEQ{PROPLIST:width, pColumnNumber} = pColumnSize * SELF.WidthChange
        END
    END


!---------------------------------------------------------------------------
jrtResizeClass.HideColumn  PROCEDURE (LONG pColumnNumber,BYTE pHide=1)
    CODE
    jrtdbg('Hide / UnHide Column No.: ' & pColumnNumber)

    IF SELF._ListFEQ{PROPLIST:Exists, pColumnNumber} = TRUE
        SELF.ColumnSizes.ColumnNumber = pColumnNumber
        GET(SELF.ColumnSizes, SELF.ColumnSizes.ColumnNumber)
        IF ERRORCODE() = FALSE
            CASE pHide
            OF FALSE
                SELF._ListFEQ{PROPLIST:width + PROPLIST:Group, pColumnNumber} = (SELF.ColumnSizes.ColumnGroupSize * SELF.WidthChange)
                SELF._ListFEQ{PROPLIST:width, pColumnNumber} = (SELF.ColumnSizes.ColumnSize * SELF.WidthChange)
            OF TRUE
                SELF._ListFEQ{PROPLIST:width + PROPLIST:Group, pColumnNumber} = 0
                SELF._ListFEQ{PROPLIST:width, pColumnNumber} = 0
            END
        END
    END


!---------------------------------------------------------------------------
jrtResizeClass.ResizeGroup  PROCEDURE (LONG pColumnNumber,LONG pGroupSize)
    CODE
    jrtdbg('Resize a group')

    IF SELF._ListFEQ{PROPLIST:Exists, pColumnNumber} = TRUE
        SELF.ColumnSizes.ColumnNumber = pColumnNumber
        GET(SELF.ColumnSizes, SELF.ColumnSizes.ColumnNumber)
        IF ERRORCODE() = FALSE
            SELF._ListFEQ{PROPLIST:width + PROPLIST:Group, pColumnNumber} = pGroupSize
            jrtdbg('Resize Group Number: ' & SELF.ColumnSizes.GroupNumber)
        END
    END


!---------------------------------------------------------------------------
jrtResizeClass.ResetColumnSizes  PROCEDURE
    CODE
    jrtdbg('Reset Column Sizes')
    SELF.CalculateWidthChange()

    SELF.ColumnNumber = 0 
    LOOP
        SELF.ColumnNumber += 1
        IF SELF._ListFEQ{PROPLIST:Exists, SELF.ColumnNumber} = FALSE
            BREAK
        ELSE
            SELF.ColumnSizes.ColumnNumber = SELF.ColumnNumber
            GET(SELF.ColumnSizes, SELF.ColumnSizes.ColumnNumber)
            IF ERRORCODE() = FALSE
                SELF._ListFEQ{PROPLIST:width + PROPLIST:Group, SELF.ColumnNumber} = SELF.ColumnSizes.ColumnGroupSize * SELF.WidthChange
                SELF._ListFEQ{PROPLIST:width, SELF.ColumnNumber} = SELF.ColumnSizes.ColumnSize * SELF.WidthChange
                jrtdbg('Reset Column ' & SELF.ColumnSizes.ColumnNumber & ': ' & SELF.ColumnSizes.ColumnSize * SELF.WidthChange)
            END
        END
    END


!---------------------------------------------------------------------------
jrtdbg  PROCEDURE   (String pDebugString)  
DB  CString(SIZE(pDebugString)+12)  ! define a variable that has the same size as the parameter we receive plus 12 characters 
  CODE
  DB = 'jrtResize: ' & pDebugString
  jrtOutputDebugString(DB)