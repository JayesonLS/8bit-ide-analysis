;░▒▓█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█▓▒░
;░▒▓█         Tool for logging access to a range of ports                 █▓▒░
;░▒▓█                           Data segment                              █▓▒░
;░▒▓█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▓▒░

Header          db      '■─[ Logger ]───────────────────[ Installed ]─■',0Dh,0Ah
                db      '│ Tool for logging access to a range of ports│',0Dh,0Ah
                db      '■────────────────────────────────────────────■',0Dh,0Ah,'$'
BadOption       db      '■─[ Logger ]───────────────────────[ Error ]─■',0Dh,0Ah
                db      '│  Invalid option - see below legal options  │',0Dh,0Ah
                db      '■────────────────────────────────────────────■',0Dh,0Ah
HelpText        db      '■─[ Logger ]────────────────────────[ Help ]─■',0Dh,0Ah
                db      '│ Tool for logging access to a range of ports│',0Dh,0Ah
                db      '│ Syntax : Logger {/SLT}; Available options: │',0Dh,0Ah
                db      '■────────────────────────────────────────────■',0Dh,0Ah,'$'
