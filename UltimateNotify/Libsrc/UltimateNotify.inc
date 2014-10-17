
NotifyCodeQueueType QUEUE,TYPE
NotifyCode              UNSIGNED
                    END

UltimateNotify      CLASS,TYPE,MODULE('UltimateNotify.CLW'),LINK('UltimateNotify.CLW')   !,_ABCLinkMode_),DLL(_ABCDllMode_)
!
!Properties
!----------

qNotifyCode             &NotifyCodeQueueType


!Methods
!-------

CONSTRUCT               PROCEDURE()
DESTRUCT                PROCEDURE()
InitWindow              PROCEDURE()

AddNotifyCode           PROCEDURE(UNSIGNED NotifyCode),VIRTUAL
FindNotifyCode          PROCEDURE(UNSIGNED pNotifyCode),BYTE

OnNotify                PROCEDURE(),BYTE,VIRTUAL !A Registered Method
HandleNotify            PROCEDURE(UNSIGNED NotifyCode, SIGNED NotifyThread,LONG NotifyParameter),VIRTUAL

                    END



    
