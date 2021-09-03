;Tool for logging access to a range of ports

;Data segment

Header          db      'Logger - Tool for logging access to a range of ports',0Dh,0Ah
                db      'Installed. Reboot to uninstall.',0Dh,0Ah,'$'
BadOption       db      'Invalid option(s)',0Dh,0Ah
                db      0Dh,0Ah
HelpText        db      'Syntax : Logger {/SLT}',0Dh,0Ah
                db      0Dh,0Ah
                db      'Available options:',0Dh,0Ah
                db      'TODO: Add options',0Dh,0Ah,'$'
