@echo off
:: Automatically elevate the script to run as Administrator
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)
IF %errorlevel% NEQ 0 (
    echo Requesting administrative privileges...
    goto UACPrompt
) ELSE ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

:: -----------------------------------------
:: Main Corsair iCUE Logic Starts Here
:: -----------------------------------------

echo Closing iCUE application...
taskkill /f /im iCUE.exe 2>nul

echo Stopping all Corsair services...
:: Loops through all running services starting with Corsair and stops them
for /f "tokens=1" %%s in ('wmic service where "name like 'Corsair%%'" get name ^| findstr /v /i "Name"') do (
    net stop "%%s" /y 2>nul
)

echo Configuring services to start automatically...
:: Sets all Corsair services to Automatic startup type
for /f "tokens=1" %%s in ('wmic service where "name like 'Corsair%%'" get name ^| findstr /v /i "Name"') do (
    sc config "%%s" start= auto >nul 2>&1
)

echo Restarting Corsair services...
:: Starts all Corsair services back up
for /f "tokens=1" %%s in ('wmic service where "name like 'Corsair%%'" get name ^| findstr /v /i "Name"') do (
    net start "%%s" 2>nul
)

echo Relaunching iCUE 4...
set "iCUEPath=C:\Program Files\Corsair\CORSAIR iCUE 4 Software\iCUE.exe"

if exist "%iCUEPath%" (
    start "" "%iCUEPath%"
) else (
    echo Could not find iCUE.exe at the specified path.
)

echo Done! Check if your RAM RGB is responding.
timeout /t 5 >nul
exit
