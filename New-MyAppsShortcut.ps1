<#
    .SYNOPSIS
        Adds a shortcut to a web app using the default browser.
    .DESCRIPTION
        Author:  John Seerden (https://www.srdn.io)
        Version: 1.0

        Adds a shortcut to a web app, using the default browser, in the Start Menu and/or on the User's Desktop.
    .PARAMETER ShortcutName
        Display Name of the shortcut.
    .PARAMETER ShortcutUrl
        URL associated with the shortcut.
    .PARAMETER ShortcutIconLocation
        Optional: Path to an icon to associate with the shortcut.
    .PARAMETER ShortcutOnDesktop
        Set to $true if the Shortcut needs to be added to the assigned User's Profile Desktop.
    .PARAMETER ShortcutInStartMenu
        Set to $true if the Shortcut needs to be added to the assigned User's Start Menu.
    .NOTES
        This scripts needs to run using the logged on credentials.
#>

param(
    [string]$ShortcutName         = "Add Network Printer",
    [string]$ShortcutUrl          = "c:\windows\system32\rundll32.exe",
    [string]$ShortcutIconLocation = "https://www.iconsdb.com/icons/download/caribbean-blue/printer-64.ico",
    [bool]$ShortcutOnDesktop      = $true,
    [bool]$ShortcutInStartMenu    = $true
)

Start-Transcript -Path $(Join-Path $env:temp "ShorcutMap.log")

$WScriptShell = New-Object -ComObject WScript.Shell -Verbose

if ($ShortcutOnDesktop) {
    $Shortcut = $WScriptShell.CreateShortcut("$env:USERPROFILE\Desktop\$ShortcutName.lnk")
    $Shortcut.TargetPath = $ShortcutUrl
    $Shortcut.Arguments = "SHELL32.DLL,SHHelpShortcuts_RunDLL AddPrinter"
    if ($ShortcutIconLocation) {
        $Shortcut.IconLocation = $ShortcutIconLocation
    }
    $Shortcut.Save()
}

if ($ShortCutInStartMenu) {
    $Shortcut = $WScriptShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$ShortcutName.lnk") 
    $Shortcut.TargetPath = $ShortcutUrl 
    if ($ShortcutIconLocation) {
        $Shortcut.IconLocation = $ShortcutIconLocation
    }
    $Shortcut.Save()
}

Stop-Transcript