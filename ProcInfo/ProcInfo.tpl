#TEMPLATE(ProcInfo,'Procedure Info Template - Ver 1.00'),FAMILY('ABC')
#!=====================================================================
#! Made Available by Arthur Brand and David Swindon
#! Copywrite: 2008-2014 
#! All Rights Reserved
#! Made available for use and distribution for Clarion Live
#!=====================================================================
#SYSTEM
#EQUATE(%ProcInfoVersion,'1.00')
#!=====================================================================
#!======= GLOBAL EXTENSION Template ===================================
#!=====================================================================
#EXTENSION(ProcInfoGlobal,'Procedure Info Global Template'),DESCRIPTION('Proc Info Global Template. Requires cwHHGlobal HTML Help template'),APPLICATION(ProcInfoProcedureExt(ProcInfo))
#SHEET,HSCROLL
  #TAB('Procedure Info')
    #INSERT(%VersionHeader)
   #BOXED(''),SECTION,PROP(Prop:FontName,'Arial')
      #PROMPT('Enable Application Info on alert key',Check),%GloEnableAppInfo,PROP(Prop:FontName,'Arial'),AT(10)
      #ENABLE(%GloEnableAppInfo)
        #PROMPT('App Info Alert Key',KEYCODE),%GlobalAlertKey,REQ,DEFAULT('CtrlAltI')
      #ENDENABLE
    #ENDBOXED
    #DISPLAY
  #ENDTAB
 #ENDSHEET 
#!=====================================================================
#!======= EXTENSION Template for procedures ===========================
#!=====================================================================
#EXTENSION(ProcInfoProcedureExt,'Procedure Info Extensions for this Procedure'),PROCEDURE,REQ(ProcInfoGlobal(ProcInfo)),DESCRIPTION('Procedure Info Extensions for this Procedure')
#!------ See if HTM help templates is active on this procedure --------------  
#!------ Settings for Non Source type procedure -------------------
#SHEET 
  #TAB('General'),WHERE (%ProcedureTemplate <> 'Source')
    #INSERT(%VersionHeader)
    #DISPLAY('ProcInfo General procedure Template'),PROP(Prop:FontStyle,700),PROP(Prop:FontName,'Arial'),PROP(Prop:FontColor,0008000H)
    #BOXED(''),SECTION,PROP(Prop:FontName,'Arial'),WHERE(%GloEnableAppInfo)
      #PROMPT('Disable App Info alert key for this procedure.',Check),%DisableAppInfo,AT(10,5),PROP(Prop:FontName,'Arial')
    #ENDBOXED 
    #DISPLAY  
  #ENDTAB
  #!------- Settings for Source type procedure ----------------------
  #TAB('General'),WHERE (%ProcedureTemplate = 'Source')
    #BOXED  
      #INSERT(%VersionHeader)
      #DISPLAY('The ProcInfo template is not available in this'),PROP(Prop:FontStyle,800),PROP(Prop:FontName,'Arial'),PROP(Prop:FontColor,00000FFH)
      #DISPLAY('procedure.'),PROP(Prop:FontStyle,800),PROP(Prop:FontName,'Arial'),PROP(Prop:FontColor,00000FFH)
    #ENDBOXED  
  #ENDTAB
#ENDSHEET
#!=====================================================================
#!------- App Info Alert ----------------------------------------------
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),WHERE(%GloEnableAppInfo=1 AND %DisableAppInfo = 0 ),PRIORITY(9001),DESCRIPTION(%ActiveTemplateInstanceDescription)
    #IF(%GlobalAlertKey)
0{PROP:Alrt,255} = %GlobalAlertKey  #<!%ActiveTemplateInstanceDescription
    #ENDIF
    #DECLARE(%cwHHFound,LONG)  
    #SET(%cwHHFound,%False)
    #FOR(%ActiveTemplate)
      #FOR(%ActiveTemplateInstance)
        #IF(%ActiveTemplate='cwHHProc(ABC)')
          #SET(%cwHHFound,%True)
          #BREAK
        #ENDIF
      #ENDFOR
    #ENDFOR
#ENDAT
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),WHERE(%GloEnableAppInfo=1 AND %DisableAppInfo = 0 AND %cwHHFound = 1 ),PRIORITY(9800),DESCRIPTION(%ActiveTemplateInstanceDescription)
!%ActiveTemplateInstanceDescription (BEGIN)
IF oHH.GetTopic() = ''
    #IF( %cwHHappendHTM )
  oHH.SetTopic('%Procedure.htm') #<!Default Help topic to procedure name.htm if none is set
    #ELSE 
  oHH.SetTopic('%Procedure')     #<!Default Help topic to procedure name if none is set
    #ENDIF   
END
!%ActiveTemplateInstanceDescription (END)
#ENDAT
#AT(%WindowManagerMethodCodeSection,'TakeWindowEvent','(),BYTE'),WHERE(%GloEnableAppInfo=1 AND %DisableAppInfo = 0),PRIORITY(4000),DESCRIPTION(%ActiveTemplateInstanceDescription)
      #IF(%GlobalAlertKey)
  !%ActiveTemplateInstanceDescription (BEGIN)
  CASE EVENT()
  OF EVENT:AlertKey
    IF KEYCODE() = %GlobalAlertKey
      CASE MESSAGE('Proc Name<9>: %Procedure' |
          &'|Proc Template<9>: %ProcedureTemplate' |
          &'|Proc Description<9>: %ProcedureDescription' |
          &'|Proc Changed on<9>: %(%ProcDateTime())' |
                #IF(%cwHHFound)
          &'|HelpTopic   <9>: '& oHH.GetTopic() |
                #ENDIF
          &'|App Name    <9>: %Application' |
          &'|Exe Path    <9>: '& COMMAND(0) |
          ,'Procedure information',ICON:Asterisk |
                #IF(%cwHHFound)
          ,'&OK|&Copy All|Copy &Help',, MSGMODE:CANCOPY)
                #ELSE
          ,'&OK|&Copy All',, MSGMODE:CANCOPY)
                #ENDIF
      OF 2
        SETCLIPBOARD('Proc Name: %Procedure' |
                #IF(%cwHHFound)
            &'<13,10>HelpTopic: '& CLIP(oHH.GetTopic()) |
                #ENDIF
            &'<13,10>Proc Template: %ProcedureTemplate' |
            &'<13,10>Proc Description: %ProcedureDescription' |
            &'<13,10>Proc Changed on: %(%ProcDateTime())' |
            &'<13,10>App Name: %Application' |
            &'<13,10>Exe Path: '& COMMAND(0))
                #IF(%cwHHFound)
      OF 3
        SETCLIPBOARD(CLIP(oHH.GetTopic()))
                #ENDIF
      END
    END
  END
  !%ActiveTemplateInstanceDescription (END)
      #ENDIF
#ENDAT
#!---------------------------------------------------------------------   
#GROUP(%VersionHeader)
  #DISPLAY('Clarion Live'),AT(10),PROP(Prop:FontStyle,700),PROP(Prop:FontName,'Arial'),PROP(Prop:FontColor,0FF0000H)
  #DISPLAY('Procedure Info Template and Help'),AT(10),PROP(Prop:FontStyle,700),PROP(Prop:FontName,'Arial')
  #DISPLAY('Version ' & %ProcInfoVersion),AT(10),PROP(Prop:FontStyle,700),PROP(Prop:FontName,'Arial')
#!--------------------------------------------------------------------- 
#GROUP(%ProcDateTime)
#RETURN(FORMAT(%ProcedureDateChanged, @D17B) &' '& FORMAT(%ProcedureTimeChanged, @T04B))
#!--------------------------------------------------------------------- 
