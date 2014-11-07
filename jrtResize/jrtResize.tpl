#TEMPLATE(jrtResize,'ActivateJrtResize(jrtResize)'),FAMILY('ABC','Clarion')
#! ------------------------------------------------------------------------------
#! Template for jrtResize - List column resizing
#! Copyright Joe Tailleur (2014)
#! Free to use - please submit any questions / requests to joe.tailleur@gmail.com
#! ------------------------------------------------------------------------------
#! #INCLUDE('jrtResize.tpw')
#!
#SYSTEM
    #equate(%jrtResizeVersion,'1.01')
#! ------------------------------------------------------------------
#Extension(ActivateJrtResize,'Activate jrtResizing class - Version:1:00'),Application
  #Sheet
    #Tab('General')
      #Boxed
        #Display('jrtResizing')
        #Display('Version ' & %jrtResizeVersion)
        #Display('Copyright 2014 - Joe Tailleur')
        #Prompt('Globally disable jrtResize Template',CHECK),%GlobalDisableJrtResize,AT(10,,180)
      #EndBoxed
      #Display()
    #EndTab
  #EndSheet
#AT(%AfterGlobalIncludes),WHERE(%GlobalDisableJrtResize=0)
  INCLUDE('jrtResizeClass.inc'),ONCE        ! added by jrtResizeClass
#ENDAT
#! ------------------------------------------------------------------
#! End Global Extension
#! ------------------------------------------------------------------
#Extension(jrtResizeList,'jrtResizing Procedure Extension - Version:1:00'),Procedure,REQ(ActivateJrtResize(jrtResize)),Multi
  #Sheet
    #Tab('General'),WHERE(%GlobalDisableJrtResize=1)
       #Display('jrtResize Template is disabled Globally')
    #EndTab
    #Tab('General'),WHERE(%GlobalDisableJrtResize=0)
       #Prompt('Control',CONTROL),%phControl
       #Prompt('Set Scroll Wheel to one line per wheel click',CHECK),%jrtSetScroll,AT(10,,180)
       #Prompt('Resize List when focus is gained',CHECK),%jrtResizeOnFocus,AT(10,,180)
       #Prompt('I will manually embed my resize points',CHECK),%jrtManualResize,AT(10,,180)
       #Prompt('Resize using Column Mode (default is list)',CHECK),%jrtResizeColumns,AT(10,,180)
       #Boxed,WHERE(%jrtManualResize=1)
         #Display('You will manually need to add a resize event')
         #Display('for your list after the window resize')
         #Display('Eg.: jrtResize.ResizeList()')
       #EndBoxed
    #EndTab
    #Tab('Disable')
       #Prompt('Disable jrtResize Template in this Procedure',CHECK),%LocalDisableJrtResize,AT(10,,180)
    #EndTab
    #Tab('&Classes')
      #Boxed(''),section,AT(,,,45)
        #Prompt('&Object name:',@s255),%jrtObject,default('jrtResize'& %ActiveTemplateInstance),at(50,5,110,),promptat(10,5)
        #Prompt('C&lass name:',@s255),%ClassName,default('jrtResizeClass'),at(50,20,110,),promptat(10,20)
      #EndBoxed
      #Boxed(''),section,AT(,,,45)
        #Display(%jrtObject & '.ResetColumnSizes')
        #Display(%jrtObject & '.ResizeList')
        #Display(%jrtObject & '.ResizeColumn')
      #EndBoxed
    #EndTab
  #EndSheet
#AT(%LocalDataClasses),DESCRIPTION('jrtResize - Class Definition'),WHERE(%GlobalDisableJrtResize=0 AND %LocalDisableJrtResize=0)
%jrtObject            %ClassName       ! added by jrtResizeClass
#EndAt
#AT(%DataSection),PRIORITY(7100),DESCRIPTION('jrtResize - Local Data'),WHERE(%GlobalDisableJrtResize=0 AND %LocalDisableJrtResize=0)
%jrtObject:ResizeOK    BYTE
#ENDAT
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),PRIORITY(8060),DESCRIPTION('jrtResize - Init - Save Column Sizes as defined'),WHERE(%GlobalDisableJrtResize=0 AND %LocalDisableJrtResize=0)
  %jrtObject.Init(%phControl)
#EndAT
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),PRIORITY(9100),DESCRIPTION('jrtResize - Set scroll to one line'),WHERE(%GlobalDisableJrtResize=0 AND %LocalDisableJrtResize=0 AND %jrtSetScroll=1)
  %phControl{PROP:WheelScroll} = 120
#EndAT
#AT(%WindowEventHandling,'GainFocus'),PRIORITY(6000),DESCRIPTION('jrtResize - Resize List when focus is regained'),WHERE(%GlobalDisableJrtResize=0 AND %LocalDisableJrtResize=0 AND %jrtResizeOnFocus=1 AND %jrtResizeColumns=0)
    %jrtObject.ResizeList()
#ENDAT
#AT(%WindowEventHandling,'GainFocus'),PRIORITY(6000),DESCRIPTION('jrtResize - Resize List (Check for missing columns) when focus is regained'),WHERE(%GlobalDisableJrtResize=0 AND %LocalDisableJrtResize=0 AND %jrtResizeOnFocus=1 AND %jrtResizeColumns=1)
    %jrtObject.ResizeColumns()
#ENDAT
#AT(%WindowEventHandling,'DoResize'),PRIORITY(7500),DESCRIPTION('jrtResize - Resize List After Resize'),WHERE(%GlobalDisableJrtResize=0 AND %LocalDisableJrtResize=0 AND %jrtManualResize=0 AND %jrtResizeColumns=0)
    %jrtObject.ResizeList()
#ENDAT
#AT(%WindowEventHandling,'DoResize'),PRIORITY(7500),DESCRIPTION('jrtResize - Resize List (Check for missing columns) After Resize'),WHERE(%GlobalDisableJrtResize=0 AND %LocalDisableJrtResize=0 AND %jrtManualResize=0 AND %jrtResizeColumns=1)
    %jrtObject.ResizeColumns()
#ENDAT
#AT(%WindowEventHandling,'Sized'),PRIORITY(7500),DESCRIPTION('jrtResize - Resize List After Resize'),WHERE(%GlobalDisableJrtResize=0 AND %LocalDisableJrtResize=0 AND %jrtManualResize=0 AND %jrtResizeColumns=0)
    %jrtObject.ResizeList()
#ENDAT
#AT(%WindowEventHandling,'Sized'),PRIORITY(7500),DESCRIPTION('jrtResize - Resize List (Check for missing columns) After Resize'),WHERE(%GlobalDisableJrtResize=0 AND %LocalDisableJrtResize=0 AND %jrtManualResize=0 AND %jrtResizeColumns=1)
    %jrtObject.ResizeColumns()
#ENDAT