
XMLQueueType        QUEUE,TYPE
FieldName               STRING(60)
FieldValue              STRING(10000)
                    END

!--------------------------------------------------------------------------------
UltimateXml         CLASS,TYPE,MODULE('UltimateXml.CLW'),LINK('UltimateXml.CLW')   !,_ABCLinkMode_),DLL(_ABCDllMode_)

qXML                    &XMLQueueType

Construct               PROCEDURE()
Destruct                PROCEDURE()

WriteXML                PROCEDURE(),STRING
ReadXML                 PROCEDURE(STRING pXMLString)
WriteXMLq               PROCEDURE(*QUEUE pQueue),STRING
ReadXMLq                PROCEDURE(*QUEUE pQueue,STRING pXMLString)
ClearXML                PROCEDURE()
AddFieldAndValue        PROCEDURE(STRING pField,STRING pValue)
GetValue                PROCEDURE(STRING pField),STRING

                    END


 
