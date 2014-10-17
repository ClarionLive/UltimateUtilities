#TEMPLATE(UltimateClass, 'Ultimate Class Template'),FAMILY('ABC','CW20')
#!---------------------------------------------------------------------
#!---------------------------------------------------------------------
#Extension(UltimateClassGlobal,'Ultimate Class (Global Extension)'),APPLICATION 
#PREPARE
  #INSERT(%CalcFamily, %Family)
#ENDPREPARE  
#SHEET,HSCROLL
#TAB('General')
#Display('You can add the name of your Classes below.')
#Display('The INCLUDE will automatically be added')
#Display('for you.')
#Boxed('')
#BUTTON('Classes'),MULTI(%Classes,%Class & ': ' & CHOOSE(%GlobalClass,'Global Class','Local Class') & CHOOSE(%MultiDLL,', ' & CHOOSE(%MultiDLLData,'Declared in this app','Declared in another App'),'')),INLINE 
  #PROMPT('Class Filename:',@S200),%Class                                                             
  #DISPLAY('  Do NOT add .inc to the end!')
  #PROMPT('Global Class',CHECK),%GlobalClass
  #ENABLE(%GlobalClass)
   #PROMPT('Global Class Name:',@S40),%GlobalClassName,REQ
   #PROMPT('Multi DLL',CHECK),%MultiDLL,AT(90),DEFAULT(0)
   #ENABLE(%MultiDLL=1),ClEAR
    #PROMPT('Declaration:',DROP('Declared in another App[0]|Declared in this App[1]')),%MultiDLLData,DEFAULT(0)
   #ENDENABLE
  #ENDENABLE
  #PROMPT('Procedure Extension "Init" embed',@S255),%ProcedureExtensionInit
#ENDBUTTON
#EndBoxed  
#PROMPT('Disable template',CHECK),%ucAppDisable,AT(10),DEFAULT(0) 
#ENDTAB 
#INSERT(%TabClarionVer)
#ENDSHEET

#ATSTART          
  #DECLARE(%ThisApplicationExtension)
  #DECLARE(%DataExternal)
#ENDAT

#AT(%AfterGlobalIncludes),WHERE(~%ucAppDisable)
 #FOR(%Classes)
   INCLUDE('%Class.inc'),ONCE  
 #ENDFOR
#ENDAT
	         
#AT(%DLLExportList)       
#FOR(%Classes)
#IF(%MultiDLL=1) 
  #IF( %MultiDLLData=1)
    #IF(~%ucAppDisable)    
  $%GlobalClassName                     @? 
    #ENDIF
  #ENDIF
#ENDIF 
#ENDFOR
#ENDAT

#AT(%CustomGlobalDeclarations),WHERE(~%ucAppDisable)   
#DECLARE(%ucFileName)
  #INSERT(%CalcFamily, %Family)
  #IF(%Family='LEGACY')         
  #FOR(%Classes) 
  #SET(%ucFileName,%Class & '.CLW')
  PROJECT(%ucFileName)
  #ENDFOR
  #ENDIF
#ENDAT

#AT(%GlobalData),WHERE(~%ucAppDisable)
#FOR(%Classes)
#SET(%DataExternal,'')
 #IF(%MultiDLL=1 AND %MultiDLLData=0)
  #SET(%DataExternal,',EXTERNAL,DLL(dll_mode)')
 #ENDIF  
 #IF(%GlobalClass)
%GlobalClassName         CLASS(%Class)%DataExternal 
                         END
 #ENDIF                          
#ENDFOR
#ENDAT   
#EXTENSION(UltimateClassProcedureExtension,'UltimateClass Procedure Extension'),Procedure  
#DECLARE(%ClassesToPick,%ClassToPick),Multi,Unique
#PREPARE
  #FREE(%ClassesToPick)
  #FOR(%Classes)
    #ADD(%ClassesToPick,%Classes)
    #SET(%ClassToPick,%Class)
  #ENDFOR   
#ENDPREPARE
#DISPLAY('Select Classes to include in this Procedure')
#BUTTON('Classes'),MULTI(%ClassesToPick,%ClassToPick),INLINE
  #PROMPT('Class Filename:',@S200),%ClassToPick
#ENDBUTTON
    
#GROUP(%CalcFamily, * %Family)
#IF(VarExists(%AppTemplateFamily))
  #IF(%AppTemplateFamily='CLARION')
    #SET(%Family,'LEGACY')
  #ELSE
    #SET(%Family,'ABC')
  #ENDIF
#ELSIF(VarExists(%cwtemplateversion))
  #IF(%cwtemplateversion = 'v5.5')
    #IF(VarExists(%ABCVersion))
      #SET(%Family,'ABC')
    #ELSE
      #SET(%Family,'LEGACY')
    #ENDIF
  #ELSE
    #IF(%cwtemplateversion = 'v2.003')
      #SET(%Family,'LEGACY')
    #ELSE
      #SET(%Family,'ABC')
    #ENDIF
  #ENDIF
#ENDIF

#GROUP(%TabClarionVer)
#TAB('Template Set')
  #DISPLAY
  #DISPLAY('Current Template Set being used by this app.')
  #DISPLAY
  #DISPLAY('This will be set automatically for you once a compile has')
  #DISPLAY('been performed.')
  #DISPLAY
  #ENABLE(%False)
    #PROMPT('Template Set:',@S10),%Family,Default(''),AT(90,,95,10)
  #ENDENABLE
  #DISPLAY
#ENDTAB

