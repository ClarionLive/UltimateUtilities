                    MEMBER()
 

    INCLUDE('EQUATES.CLW')
    INCLUDE('UltimateXml.INC'),ONCE
    INCLUDE('UltimateDebug.inc'),ONCE

    INCLUDE('xfiles.inc'),ONCE


                    MAP
                    END

ud                  UltimateDebug,THREAD

!----------------------------------------
UltimateXml.Construct       PROCEDURE()
!----------------------------------------
    CODE

        ud.DebugOff = FALSE
        ud.DebugPrefix = '!'
        SELF.qXML                           &= NEW XMLQueueType

        RETURN


!---------------------------------------
UltimateXml.Destruct        PROCEDURE()
!---------------------------------------
    CODE
        
        FREE(SELF.qXML)
        DISPOSE(SELF.qXML)
        
        RETURN


!-----------------------------------------
UltimateXml.ClearXML        PROCEDURE()   
!-----------------------------------------

    CODE

        FREE(SELF.qXML)
        CLEAR(SELF.qXML)

        RETURN  
        

!-----------------------------------------
UltimateXml.ReadXML PROCEDURE(STRING pXMLString) !,STRING
!-----------------------------------------

xml                     xFileXML

    CODE
        
        SELF.ClearXML()
        xml.Load(SELF.qXML,pXMLString,LEN(CLIP(pXMLString)),'UltimateXml','Data')

        RETURN     
        
!-----------------------------------------
UltimateXml.WriteXML        PROCEDURE() !STRING
!-----------------------------------------

xml                             xFileXML

    CODE
        
        xml.OmitXMLHeader = 1
        xml.Save(SELF.qXML,'UltimateXml','Data')
        
        RETURN xml.xmlData 


!-----------------------------------------
UltimateXml.ReadXMLq        PROCEDURE(*QUEUE pQueue,STRING pXMLString) !,STRING
!-----------------------------------------

xml                             xFileXML

    CODE
        
        SELF.ClearXML()
        xml.Load(pQueue,pXMLString,LEN(CLIP(pXMLString)),'UltimateXml','Data')

        RETURN     
        
!-----------------------------------------
UltimateXml.WriteXMLq       PROCEDURE(*QUEUE pQueue) !STRING
!-----------------------------------------

xml                             xFileXML

    CODE
        
        xml.OmitXMLHeader = 1
        xml.Save(pQueue,'UltimateXml','Data')
        
        RETURN xml.xmlData
        
!-----------------------------------------
UltimateXml.AddFieldAndValue        PROCEDURE(STRING pField,STRING pValue)
!-----------------------------------------

    CODE
       
        CLEAR(SELF.qXML)
        SELF.qXML.FieldName = UPPER(pField)
        GET(SELF.qXML,SELF.qXML.FieldName)
        IF ERROR()
            ADD(SELF.qXML)
        END
        SELF.qXML.FieldValue = pValue
        PUT(SELF.qXML)
        
        RETURN

!-----------------------------------------
UltimateXml.GetValue        PROCEDURE(STRING pField)  !,STRING
!-----------------------------------------

    CODE

        CLEAR(SELF.qXML)
        SELF.qXML.FieldName = UPPER(pField)
        GET(SELF.qXML,SELF.qXML.FieldName)
        
        RETURN  CLIP(SELF.qXML.FieldValue )

 

