# Reset Corsair iCUE Services

A small Windows batch script that force-restarts Corsair iCUE and every Corsair
Windows service without a full reboot. It re-launches itself with Administrator
privileges, closes `iCUE.exe`, stops every service whose name starts with
`Corsair`, sets those services to start automatically, starts them again, and
relaunches iCUE.

Use it when iCUE is stuck, the RAM RGB stops responding, or the Corsair services
are hung and a reboot is overkill.

## How it works

The script has two parts:

1. Self-elevation to Administrator (UAC prompt).
2. Closing iCUE, cycling all Corsair services, and relaunching iCUE.

## Part 1 - Self-elevation to Administrator

```bat
@echo off
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
    >nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
    >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)
IF %errorlevel% NEQ 0 (
    echo Requesting administrative privileges...
    goto UACPrompt
) ELSE ( goto gotAdmin )
