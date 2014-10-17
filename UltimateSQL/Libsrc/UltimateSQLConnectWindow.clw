Window              WINDOW('Connect'),AT(,,364,165),CENTER,GRAY,FONT('MS Sans Serif',8)
                        SHEET,AT(2,2,360,161),USE(?SHEET1)
                            TAB('Tab1'),USE(?TAB1)
                                PANEL,AT(29,28,301,99),USE(?PANEL2),BEVEL(1)
                                STRING('Connecting to Server....'),AT(101,62),USE(?STRING6), |
                                    FONT('Arial',14,,FONT:bold+FONT:italic)
                            END
                            TAB('Tab2'),USE(?TAB2)
                                PANEL,AT(18,14,322,105),USE(?PANEL1),BEVEL(1)
                                COMBO(@s200),AT(85,25,224,12),USE(TheServer),VSCROLL,DROP(10), |
                                    FROM(SQLServers),FORMAT('1020L(2)@s255@')
                                LIST,AT(85,42,224,11),USE(?LISTAuthentication),DROP(2), |
                                    FROM('Windows Authentication|SQL Server Authentication')
                                ENTRY(@s200),AT(85,58,224),USE(TheUserName)
                                ENTRY(@s200),AT(85,76,224),USE(ThePassword),PASSWORD
                                COMBO(@s200),AT(85,93,224,12),USE(TheDatabase),VSCROLL,DROP(10), |
                                    FROM(SQLDatabases),FORMAT('1020L(2)|M@s255@')
                                BUTTON('OK'),AT(201,131,65,21),USE(?OkButton),DEFAULT
                                BUTTON('Cancel'),AT(271,131,69,21),USE(?CancelButton)
                                STRING('Username:'),AT(46,62),USE(?STRING3)
                                STRING('Database:'),AT(47,96),USE(?STRING2)
                                STRING('Server Host:'),AT(41,28),USE(?STRING1)
                                STRING('Password:'),AT(47,79),USE(?STRING4)
                                STRING('Authentication:'),AT(33,44),USE(?STRING5)
                                BUTTON('Test'),AT(18,131,65,21),USE(?BUTTONTest)
                            END
                        END
                    END