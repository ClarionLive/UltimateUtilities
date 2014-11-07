#TEMPLATE(ProcInfo,'Procedure Info Template - Ver 1.00'),FAMILY('ABC')
#!=====================================================================
#! Made Available by Arthur Brand and David Swindon
#! Copywrite: 2008-2014 
#! All Rights Reserved
#! Made available for use and distribution for Clarion Live
#!=====================================================================
#SYSTEM
#Equate(%ProcInfoVersion,'1.00')
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
#! 
#EXTENSION(ProcInfoProcedureExt,'Procedure Info Extensions for this Procedure'),PROCEDURE,REQ(ProcInfoGlobal(ProcInfo))
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
#COMMENT(84)
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),WHERE(%GloEnableAppInfo=1 AND %DisableAppInfo = 0 ),PRIORITY(9001)
#DECLARE(%cwHHFound,LONG)  
  #SET(%cwHHFound,0)
  #FOR(%ActiveTemplate)
    #FOR(%ActiveTemplateInstance)
      #IF(%ActiveTemplate='cwHHProc(ABC)')
        #SET(%cwHHFound,1)
        #BREAK
      #ENDIF
    #ENDFOR
  #ENDFOR
  
  #IF(%GlobalAlertKey)
    ALERT(%GlobalAlertKey)                                      #<!ProcInfo Template 
  #ENDIF
#ENDAT
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),WHERE(%GloEnableAppInfo=1 AND %DisableAppInfo = 0 AND %cwHHFound = 1 ),PRIORITY(9800)
 
    #IF( %cwHHappendHTM )
     IF CLIP(oHH.GetTopic()) =''                                  #<!ProcInfo Template mod 
       oHH.SetTopic('%Procedure.htm')                             #<!Default Help topic to procedure name.htm if none is set !ProcInfo Template mod
     END        
    #ELSE 
     IF CLIP(oHH.GetTopic()) =''                                  #<!ProcInfo Template mod 
       oHH.SetTopic('%Procedure')                                #<!Default Help topic to procedure name if none is set !ProcInfo Template mod   
     END  
    #ENDIF   
                                                       #<!ProcInfo Template mod
    
#ENDAT
#AT(%WindowManagerMethodCodeSection,'TakeWindowEvent','(),BYTE'),WHERE(%GloEnableAppInfo=1 AND %DisableAppInfo = 0),PRIORITY(4000)
  #IF(%GlobalAlertKey)
  CASE EVENT()                                                #<!ProcInfo Template  
  OF Event:AlertKey                                           #<!ProcInfo Template  
    IF KEYCODE() = %GlobalAlertKey                            #<!ProcInfo Template  
       #IF(%cwHHFound)
      CASE Message('Proc Name<9>: %Procedure'|                   #<!ProcInfo Template
          &'|Proc Template<9>: %ProcedureTemplate'|             #<!ProcInfo Template
          &'|Proc Description<9>: %ProcedureDescription'|       #<!ProcInfo Template 
          &'|Proc Changed on<9>: '& FORMAT('%ProcedureDateChanged',@D17B) &' '& FORMAT('%ProcedureTimeChanged',@T04B)|   #<!ProcInfo Template 
          &'|HelpTopic   <9>: '& oHH.GetTopic()|                #<!ProcInfo Template
          &'|App Name    <9>: %Application'|                    #<!ProcInfo Template
          &'|Exe Path    <9>: '& COMMAND(0)|                    #<!ProcInfo Template
          ,'Procedure information',ICON:Asterisk|               #<!ProcInfo Template  
          ,'&Ok|&Copy All|Copy &Help',1,2)                      #<!ProcInfo Template
      OF 1                                                       #<!ProcInfo Template  
      OF 2                                                       #<!ProcInfo Template  
       SETCLIPBOARD('Proc Name: %Procedure'|                    #<!ProcInfo Template  
           &'<13,10>HelpTopic: '& CLIP(oHH.GetTopic())|
           &'<13,10>Proc Template: %ProcedureTemplate'|         
           &'<13,10>Proc Description: %ProcedureDescription'|     
           &'<13,10>Proc Changed on: '& FORMAT('%ProcedureDateChanged',@D17B) &' '& FORMAT('%ProcedureTimeChanged',@T04B)|             
           &'<13,10>App Name: %Application'|                    #<!ProcInfo Template
           &'<13,10>Exe Path: '& COMMAND(0))                    #<!ProcInfo Template
      OF 3                                                       #<!ProcInfo Template
       SETCLIPBOARD(CLIP(oHH.GetTopic()))
      END                                                        #<!ProcInfo Template  
       #ELSE                            
      CASE Message('Proc Name<9>: %Procedure'|                   #<!ProcInfo Template
         &'|Proc Template<9>: %ProcedureTemplate'|              #<!ProcInfo Template
          &'|Proc Description<9>: %ProcedureDescription'|       #<!ProcInfo Template 
          &'|Proc Changed on<9>: '& FORMAT('%ProcedureDateChanged',@D17B) &' '& FORMAT('%ProcedureTimeChanged',@T04B)|   #<!ProcInfo Template  
          &'|App Name    <9>: %Application'|                    #<!ProcInfo Template
          &'|Exe Path    <9>: '& COMMAND(0)|                    #<!ProcInfo Template
          ,'Procedure information',ICON:Asterisk|               #<!ProcInfo Template
          ,'&Ok|&Copy All',1,2)                                 #<!ProcInfo Template
      OF 1                                                       #<!ProcInfo Template
      OF 2                                                       #<!ProcInfo Template
       SETCLIPBOARD('Curr Process: %Procedure'|                 #<!ProcInfo Template
           &'<13,10>Proc Template: %ProcedureTemplate'|         
           &'<13,10>Proc Description: %ProcedureDescription'|     
           &'<13,10>Proc Changed on: '& FORMAT('%ProcedureDateChanged',@D17B) &' '& FORMAT('%ProcedureTimeChanged',@T04B)| 
           &'<13,10>App Name: %Application'|                    #<!ProcInfo Template
           &'<13,10>Exe Path: '& COMMAND(0))                    #<!ProcInfo Template
      END                                                        #<!ProcInfo Template
       #ENDIF                                             
    END !IF                                                   #<!ProcInfo Template 
  END !CASE OF                                                #<!ProcInfo Template 
  #ENDIF
#ENDAT  
#!---------------------------------------------------------------------   
#GROUP(%VersionHeader)
    #DISPLAY('Clarion Live'),AT(10),PROP(Prop:FontStyle,700),PROP(Prop:FontName,'Arial'),PROP(Prop:FontColor,0FF0000H)
    #DISPLAY('Procedure Info Template and Help'),AT(10),PROP(Prop:FontStyle,700),PROP(Prop:FontName,'Arial')
    #DISPLAY('Version ' & %ProcInfoVersion),AT(10),PROP(Prop:FontStyle,700),PROP(Prop:FontName,'Arial')

#!--------------------------------------------------------------------- 
  

