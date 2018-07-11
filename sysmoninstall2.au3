; Script must be compiled before it can be run (using AutoIT to execute script will fail silently)
; The sysmon config used is thanks to https://github.com/olafhartong/sysmon-modular

#pragma compile(Out, sysmoninstall.exe)
#pragma compile(ExecLevel, asInvoker)
#pragma compile(Compatibility, win7)
#pragma compile(UPX, False)
#pragma compile(FileDescription, "Sysmon installation and update script")
#pragma compile(ProductName, SysmonInstall)
#pragma compile(ProductVersion, 0.1)
#pragma compile(FileVersion, 0.1)
#pragma compile(LegalCopyright, © Derek Armstrong)
#pragma compile(CompanyName, 'dsplice.com')
#pragma compile(x64, True)
#pragma compile(inputboxes, False)
#pragma compile(Console, True)
#pragma compile(AutoItExecuteAllowed, False)

Static Global $bIsDebug = True
Static Global $sSysmonExe = "\\server01\share01\Sysmon64.exe"
Static Global $sSysmonCfg = "\\server01\share01\sysmonconfig.xml"

If Not IsAdmin() Then
	ConsoleWrite("ERROR: Not running as admin user." & @CRLF)
	Exit(1) ;Unrecoverable Error
EndIf

If RunWait("sc qc sysmon", "", @SW_HIDE, 0x10000) Then
	If $bIsDebug Then
		ConsoleWrite("DEBUG: Sysmon is not installed." & @CRLF)
	EndIf ;IsDebug
	InstallSysmon()
	Exit(0)
EndIf

If Not FileExists("C:\Windows\Sysmon.exe") Then
	ConsoleWrite("ERROR: Unable to locate Sysmon.exe." & @CRLF)	
	Exit(1) ;Unrecoverable Error
EndIf

If Not FileExists($sSysmonExe) Then
	ConsoleWrite("ERROR: Unable to locate " & $sSysmonExe & @CRLF)	
	Exit(1) ;Unrecoverable Error
EndIf

If Not FileExists($sSysmonCfg) Then
	ConsoleWrite("ERROR: Unable to locate " & $sSysmonCfg & @CRLF)	
	Exit(1) ;Unrecoverable Error
EndIf

Local $sLocalFileVersion = FileGetVersion("C:\Windows\Sysmon.exe", "FileVersion")
Local $sRemoteFileVersion = FileGetVersion($sSysmonExe, "FileVersion")

If $sLocalFileVersion < $sRemoteFileVersion Then
	If $bIsDebug Then
		ConsoleWrite("DEBUG: Sysmon version is less than Sysmon version on server." & @CRLF)
	EndIf ;IsDebug
	UninstallSysmon()
	sleep(5)
	InstallSysmon()
	Exit(0) ;Normal exit
EndIf

If $sLocalFileVersion > $sRemoteFileVersion Then
	ConsoleWrite("ERROR: Sysmon.exe at unknown version." & @CRLF)
	Exit(1) ;Unrecoverable Error
EndIf

If $sLocalFileVersion = $sRemoteFileVersion Then
	If $bIsDebug Then
		ConsoleWrite("DEBUG: Sysmon.exe is at correct version." & @CRLF)
	EndIf ;IsDebug
	UpdateSysmon()
	Exit(0) ;Success
EndIf

Func InstallSysmon()
	If RunWait($sSysmonExe & " -accepteula -i " & $sSysmonCfg, "", @SW_HIDE, 0x10000) Then
		ConsoleWrite("ERROR: Unable to install Sysmon" & @CRLF)
		Exit(1) ;Unrecoverable Error
	EndIf
	If $bIsDebug Then
		ConsoleWrite("DEBUG: Sysmon installed." & @CRLF)
	EndIf ;IsDebug
	RunWait("wevtutil sl Microsoft-Windows-Sysmon/Operational /ms:209715200", "", @SW_HIDE, 0x10000) ;Set eventlog size at 200MB
	Exit(0) ;Success
EndFunc  ;InstallSysmon

Func UninstallSysmon()
	If RunWait("C:\Windows\Sysmon.exe -accepteula -u", "", @SW_HIDE, 0x10000) Then
		ConsoleWrite("ERROR: Unable to uninstall Sysmon." & @CRLF)
		Exit(1) ;Unrecoverable Error
	EndIf
	If $bIsDebug Then
		ConsoleWrite("DEBUG: Sysmon uninstalled." & @CRLF)
	EndIf ;IsDebug
EndFunc  ;UninstallSysmon

Func UpdateSysmon()
	If RunWait("C:\Windows\Sysmon.exe -accepteula -c " & $sSysmonCfg, "", @SW_HIDE, 0x10000) Then
		ConsoleWrite("ERROR: Unable to update Sysmon." & @CRLF)
		Exit(1) ;Unrecoverable Error
	EndIf
	If $bIsDebug Then
		ConsoleWrite("DEBUG: Sysmon config updated." & @CRLF)
	EndIf ;IsDebug
	Exit(0) ;Success
EndFunc  ;UpdateSysmon
	