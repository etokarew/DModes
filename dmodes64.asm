; Консольная утилита Windows NT x64
;  для просмотра режимов работы указанного устройства вывода графики
; Написана на flat assembler 1.72
;  https://flatassembler.net/docs.php

format PE64 console 4.0
entry start

include '%appdata%\fasm\include\win64a.inc'
include '%appdata%\fasm\include\api\msvcrt.inc'
include '%appdata%\fasm\include\api\user32.inc'
include '%appdata%\fasm\include\encoding\utf8.inc'

section '.idata' import data readable
    library msvcrt,'MSVCRT.DLL',\
        user32,'USER32.DLL'

section '.data' data readable writeable
    _tab db 9d,0 ; горизонтальная табуляция
    _lf db 10d,0 ; новая строка
    _cr db 13d,0 ; возврат каретки

    _cls db 'cls',0
    _pause db 'pause',0
    _russian db 'Russian',0
    _title db 'DModes 1.01 [x64]',0

    _input db 155d,32d,0
    _dev_input_req db 207d,238d,230d,224d,235d,243d,233d,241d,242d,224d,\
        44d,32d,\
        226d,226d,229d,228d,232d,242d,229d,\
        32d,\
        239d,238d,240d,255d,228d,234d,238d,226d,251d,233d,\
        32d,\
        237d,238d,236d,229d,240d,\
        32d,\
        243d,241d,242d,240d,238d,233d,241d,242d,226d,224d,\
        32d,40d,45d,49d,32d,\
        228d,235d,255d,\
        32d,\
        226d,251d,245d,238d,228d,224d,\
        41d,58d,0
    _mode_input_req db 207d,238d,230d,224d,235d,243d,233d,241d,242d,224d,\
        44d,32d,\
        226d,226d,229d,228d,232d,242d,229d,\
        32d,\
        239d,238d,240d,255d,228d,234d,238d,226d,251d,233d,\
        32d,\
        237d,238d,236d,229d,240d,\
        32d,\
        240d,229d,230d,232d,236d,224d,\
        32d,40d,45d,49d,32d,\
        228d,235d,255d,\
        32d,\
        226d,238d,231d,226d,240d,224d,242d,224d,\
        41d,58d,0
    _scan_err db 206d,248d,232d,225d,234d,224d,\
        32d,\
        226d,226d,238d,228d,224d,\
        33d,0

section '.bss' readable writeable ; block started by symbol
    dispdev DISPLAY_DEVICE
    devmode DEVMODE
    dv dd ?
    md dd ?
    lf db ?

section '.text' code readable executable
    start:
        sub rsp,8 ; выравнивание стека по dqword (16 байт, 128 бит)

        mov [dispdev.cb],sizeof.DISPLAY_DEVICE
        ;mov [dispdev.StateFlags],DISPLAY_DEVICE_ATTACHED_TO_DESKTOP
        mov [devmode.dmSize],sizeof.DEVMODE

        invoke setlocaleA,NULL,_russian

    device:
        invoke systemA,_cls
        invoke printfA,'%s',_title
        call new_line
        call new_line
        invoke printfA,'%s',_dev_input_req
        call new_line
        call input
        invoke scanfA,'%d%c',dv,lf
        call dc_check
        mov edx,[dv]
        inc edx
        jz exit
        invoke EnumDisplayDevicesA,NULL,[dv],dispdev,0
        test rax,rax
        jz device
        call new_line
        invoke printfA,'%sDeviceName%s%s%s',_tab,_tab,_tab,dispdev.DeviceName
        call new_line
        invoke printfA,'%sDeviceString%s%s%s',_tab,_tab,_tab,dispdev.DeviceString
        call new_line
        invoke printfA,'%sDeviceID%s%s%s',_tab,_tab,_tab,dispdev.DeviceID
        call new_line
        call new_line

    mode:
        invoke printfA,'%s',_mode_input_req
        call new_line
        call input
        invoke scanfA,'%d%c',md,lf
        call dc_check
        mov edx,[md]
        inc edx
        jz device
        invoke EnumDisplaySettingsA,dispdev.DeviceName,[md],devmode
        test rax,rax
        jz mode
        call new_line
        invoke printfA,'%sdmDeviceName%s%s%s',_tab,_tab,_tab,devmode.dmDeviceName
        call new_line
        invoke printfA,'%sdmSpecVersion%s%s%d',_tab,_tab,_tab,[devmode.dmSpecVersion]
        call new_line
        invoke printfA,'%sdmDriverVersion%s%s%d',_tab,_tab,_tab,[devmode.dmDriverVersion]
        call new_line
        ;invoke printfA,'%sdmSize%s%s%s%d',_tab,_tab,_tab,_tab,[devmode.dmSize]
        ;call new_line
        invoke printfA,'%sdmDriverExtra%s%s%d',_tab,_tab,_tab,[devmode.dmDriverExtra]
        call new_line
        invoke printfA,'%sdmFields%s%s%d',_tab,_tab,_tab,[devmode.dmFields]
        call new_line
        call new_line
        invoke printfA,'%sdmOrientation%s%s%d',_tab,_tab,_tab,[devmode.dmOrientation]
        call new_line
        invoke printfA,'%sdmPaperSize%s%s%d',_tab,_tab,_tab,[devmode.dmPaperSize]
        call new_line
        invoke printfA,'%sdmPaperLength%s%s%d',_tab,_tab,_tab,[devmode.dmPaperLength]
        call new_line
        invoke printfA,'%sdmPaperWidth%s%s%d',_tab,_tab,_tab,[devmode.dmPaperWidth]
        call new_line
        invoke printfA,'%sdmScale%s%s%s%d',_tab,_tab,_tab,_tab,[devmode.dmScale]
        call new_line
        invoke printfA,'%sdmCopies%s%s%d',_tab,_tab,_tab,[devmode.dmCopies]
        call new_line
        invoke printfA,'%sdmDefaultSource%s%s%d',_tab,_tab,_tab,[devmode.dmDefaultSource]
        call new_line
        invoke printfA,'%sdmPrintQuality%s%s%d',_tab,_tab,_tab,[devmode.dmPrintQuality]
        call new_line
        call new_line
        invoke printfA,'%sdmPosition.x%s%s%d',_tab,_tab,_tab,[devmode.dmPosition.x]
        call new_line
        invoke printfA,'%sdmPosition.y%s%s%d',_tab,_tab,_tab,[devmode.dmPosition.y]
        call new_line
        invoke printfA,'%sdmDisplayOrientation%s%d',_tab,_tab,[devmode.dmDisplayOrientation]
        call new_line
        invoke printfA,'%sdmDisplayFixedOutput%s%d',_tab,_tab,[devmode.dmDisplayFixedOutput]
        call new_line
        call new_line
        invoke printfA,'%sdmColor%s%s%s%d',_tab,_tab,_tab,_tab,[devmode.dmColor]
        call new_line
        invoke printfA,'%sdmDuplex%s%s%d',_tab,_tab,_tab,[devmode.dmDuplex]
        call new_line
        invoke printfA,'%sdmYResolution%s%s%d',_tab,_tab,_tab,[devmode.dmYResolution]
        call new_line
        invoke printfA,'%sdmTTOption%s%s%d',_tab,_tab,_tab,[devmode.dmTTOption]
        call new_line
        invoke printfA,'%sdmCollate%s%s%d',_tab,_tab,_tab,[devmode.dmCollate]
        call new_line
        invoke printfA,'%sdmFormName%s%s%s',_tab,_tab,_tab,devmode.dmFormName
        call new_line
        invoke printfA,'%sdmLogPixels%s%s%d',_tab,_tab,_tab,[devmode.dmLogPixels]
        call new_line
        invoke printfA,'%sdmBitsPerPel%s%s%d',_tab,_tab,_tab,[devmode.dmBitsPerPel]
        call new_line
        invoke printfA,'%sdmPelsWidth%s%s%d',_tab,_tab,_tab,[devmode.dmPelsWidth]
        call new_line
        invoke printfA,'%sdmPelsHeight%s%s%d',_tab,_tab,_tab,[devmode.dmPelsHeight]
        call new_line
        call new_line
        invoke printfA,'%sdmDisplayFlags%s%s%d',_tab,_tab,_tab,[devmode.dmDisplayFlags]
        call new_line
        invoke printfA,'%sdmNup%s%s%s%d',_tab,_tab,_tab,_tab,[devmode.dmNup]
        call new_line
        call new_line
        invoke printfA,'%sdmDisplayFrequency%s%d',_tab,_tab,[devmode.dmDisplayFrequency]
        call new_line
        call new_line
        jmp mode

    exit:
        invoke systemA,_pause
        invoke exitA,1

    dc_check:
        cmp rax,2
        jne scan_err
        mov dl,[lf]
        cmp dl,10d
        jne scan_err
        ret
    scan_err:
        invoke printfA,'%s',_scan_err
        call new_line
        invoke systemA,_pause
        invoke flushall
        jmp device

    input:
        invoke printfA,'%s',_input
        ret

    new_line:
        invoke printfA,'%s%s',_lf,_cr
        ret