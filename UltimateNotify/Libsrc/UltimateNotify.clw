                    MEMBER()
 
    INCLUDE('EQUATES.CLW')
    INCLUDE('UltimateNotify.INC'),ONCE
    INCLUDE('UltimateDebug.inc'),ONCE

                    MAP
                    END

ud                  UltimateDebug,THREAD

UltimateNotify.CONSTRUCT    PROCEDURE()

    CODE
        
        SELF.qNotifyCode         &= NEW NotifyCodeQueueType

    
UltimateNotify.DESTRUCT     PROCEDURE()

    CODE
        
        FREE(SELF.qNotifyCode)
        DISPOSE(SELF.qNotifyCode)
        
        
UltimateNotify.InitWindow PROCEDURE()

    CODE
        
        REGISTER(EVENT:Notify, ADDRESS(SELF.OnNotify), ADDRESS(SELF))

        
UltimateNotify.AddNotifyCode        PROCEDURE(UNSIGNED pNotifyCode)  

    CODE
        
        IF ~SELF.FindNotifyCode(pNotifyCode)
            SELF.qNotifyCode.NotifyCode = pNotifyCode
            ADD(SELF.qNotifyCode,SELF.qNotifyCode.NotifyCode)
        END
        
        
UltimateNotify.FindNotifyCode       PROCEDURE(UNSIGNED pNotifyCode)  !,BYTE

Result                                  BYTE(TRUE)

    CODE
        
        CLEAR(SELF.qNotifyCode)
        SELF.qNotifyCode.NotifyCode = pNotifyCode
        GET(SELF.qNotifyCode,SELF.qNotifyCode.NotifyCode)
        IF ERRORCODE()
            Result = FALSE
        END
            
        RETURN  Result
        
        
UltimateNotify.OnNotify     PROCEDURE()  !Byte

NotifyCode                      UNSIGNED,AUTO
NotifyThread                    SIGNED,AUTO
NotifyParameter                 LONG,AUTO

    CODE
        
        ud.DebugOff = FALSE
        ud.DebugPrefix = '!'
        
!!        IF EVENT() = EVENT:Notify
        IF NOTIFICATION(NotifyCode,NotifyThread,NotifyParameter)
            IF SELF.FindNotifyCode(NotifyCode)
                SELF.HandleNotify(NotifyCode,NotifyThread,NotifyParameter)
            END
        END
        
!!        END
        
        RETURN 0

        
UltimateNotify.HandleNotify PROCEDURE(UNSIGNED NotifyCode, SIGNED NotifyThread,LONG NotifyParameter)

    CODE
        
        RETURN 
        
        
        
        