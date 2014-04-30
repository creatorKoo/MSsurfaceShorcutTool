; Made by NineTiger - 2014 / April / 18
; for MS Surface type cover keyboard
; http://blog.ninetiger.com
; E-Mail : admin@ninetiger.com

; HOW TO USE
; Shift + CTRL + UP         - Vol Up
; Shift + CTRL + DOWN       - Vol Down
; Shift + CTRL + ALT + UP   - LCD Brightness Up
; Shift + CTRL + ALT + Down - LCD Brightness Down
; ALT + i 		  			- Insert
; CTRL + ALT + t 			- Always On Top Maker

; SETTINGS
Brightness_Delay:=1000
BG_color=1A1A1A
Text_color=FFFFFF
Bar_color=666666
Brightness_OSD_Center:=1

; HOTKEYS
^+Up::Send {Volume_Up}
^+Down::Send {Volume_Down}
!^+Up::Gosub Brighten
!^+Down::Gosub Dim
!i::Send {Insert}
!^t::Winset, Alwaysontop, ,A

; Setting LCD Brightenss
LCDBrightness(Brightness)
	{
	hLCD := DllCall("CreateFile"
	, Str, "\\.\LCD"
	, UInt, 0x80000000 | 0x40000000
	, UInt, 0x1 | 0x2
	, UInt, 0
	, UInt, 0x3
	, UInt, 0, UInt, 0)
	if hLCD <> -1
		{
		FILE_DEVICE_VIDEO := 0x00000023, METHOD_BUFFERED := 0, FILE_ANY_ACCESS := 0
		VarSetCapacity(DISPLAY_BRIGHTNESS, 3, 0)
		NumPut(0x03, DISPLAY_BRIGHTNESS, 0, "UChar")
		NumPut(Brightness, DISPLAY_BRIGHTNESS, 1, "UChar")
		NumPut(Brightness, DISPLAY_BRIGHTNESS, 2, "UChar")
		. DllCall("DeviceIoControl"
		, UInt, hLCD
		, UInt, (FILE_DEVICE_VIDEO<<16 | 0x127<<2 | METHOD_BUFFERED<<14 | FILE_ANY_ACCESS)
		, UInt, &DISPLAY_BRIGHTNESS, UInt, 3
		, UInt, 0, UInt, 0
		, UIntP, dwBytesReturned
		, UInt, 0) "`nErrorLevel:`t`t" ErrorLevel "`nLastError:`t`t" A_LastError
		DllCall("CloseHandle", UInt, hLCD)
		}
	}

; Bright LCD Brightness +5
Brighten:
	LCDBrightness:=GETLCDB()

	if (LCDBrightness=100){
		return
		} 
	LCDBrightness:= LCDBrightness + 5
	if (LCDBrightness>99){
		LCDBrightness=100
		}
	LCDBrightness(LCDBrightness)

	Brightness_Show_OSD(LCDBrightness)
Return

; Dim LCD Brightness -5
Dim:
	LCDBrightness:=GETLCDB()

	if (LCDBrightness=0){
		return
		}
	LCDBrightness:= LCDBrightness - 5
	if (LCDBrightness<1){
		LCDBrightness=0
		}
	LCDBrightness(LCDBrightness)

	Brightness_Show_OSD(LCDBrightness)
Return

; Get Current LCD Brightntess
GETLCDB()
	{
	Brightness:=0
	hLCD := DllCall("CreateFile"
	, Str, "\\.\LCD"
	, UInt, 0x80000000 | 0x40000000
	, UInt, 0x1 | 0x2
	, UInt, 0
	, UInt, 0x3
	, UInt, 0, UInt, 0)
	if hLCD <> -1
		{
		FILE_DEVICE_VIDEO := 0x00000023, METHOD_BUFFERED := 0, FILE_ANY_ACCESS := 0
		VarSetCapacity(DISPLAY_BRIGHTNESS, 3, 0)
		NumPut(0x03, DISPLAY_BRIGHTNESS, 0, "UChar")
		NumPut(Brightness, DISPLAY_BRIGHTNESS, 1, "UChar")
		NumPut(Brightness, DISPLAY_BRIGHTNESS, 2, "UChar")
		. DllCall("DeviceIoControl"
		, UInt, hLCD
		, UInt, (FILE_DEVICE_VIDEO<<16 | 0x126<<2 | METHOD_BUFFERED<<14 | FILE_ANY_ACCESS)
		, UInt, 0, UInt, 0
		, UInt, &DISPLAY_BRIGHTNESS, UInt, 3
		, UIntP, dwBytesReturned
		, UInt, 0) "`nErrorLevel:`t`t" ErrorLevel "`nLastError:`t`t" A_LastError
		DllCall("CloseHandle", UInt, hLCD)
		return NumGet(DISPLAY_BRIGHTNESS, 1, "UChar")
		}
	return 0
	}

; Brightness On Screen Display
Brightness_Show_OSD(Brightness){
	global
	if (Brightness_OSD_Center)
	{
		mY := (A_ScreenHeight/2)-26, mX := (A_ScreenWidth/2)-165
	}
	else
	{
		SysGet m, MonitorWorkArea, 1
		mY := mBottom-52-200, mX := mRight-330-200
	}
	if (!Brightness_OSD_c)
	{
		Brightness_ProgressbarOpts=CW%BG_color% CT%Text_color% CB%Bar_color% x%mX% y%mY% w330 h52 B1 FS8 WM700 WS700 FM8 ZH12 ZY3 C11
		Progress Hide %Brightness_ProgressbarOpts%,,LCD Brightness,, Tahoma
		Brightness_OSD_c:=!Brightness_OSD_c
	}
	Progress Show
	Progress % Brightness := Round(Brightness), %Brightness% `%
	SetTimer, Remove_Show_OSD, %Brightness_Delay%
}
; Remove B-OSD
Remove_Show_OSD:
	SetTimer, Remove_Show_OSD, Off
	Progress Hide %Brightness_ProgressbarOpts%,,LCD Brightness,,Tahoma
return