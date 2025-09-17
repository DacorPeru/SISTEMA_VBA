@echo off
echo ============================================
echo 🔐 Registro de SecureDbConnector.Sql.dll para VBA Excel
echo ============================================
echo.

:: Carpeta actual
set "CURDIR=%~dp0"

:: RegAsm .NET 4.x (x86 y x64)
set "REGASM32=%windir%\Microsoft.NET\Framework\v4.0.30319\regasm.exe"
set "REGASM64=%windir%\Microsoft.NET\Framework64\v4.0.30319\regasm.exe"

:: DLL a registrar
set "DLL=SecureDbConnector.Sql.dll"

:: Auto-elevar si no hay privilegios de admin
>nul 2>&1 "%SystemRoot%\system32\cacls.exe" "%SystemRoot%\system32\config\system"
if not "%errorlevel%"=="0" (
    echo Solicitando privilegios de administrador...
    powershell -NoProfile -WindowStyle Normal -Command "Start-Process -FilePath '%~f0' -Verb RunAs -Wait"
    goto :fin
)

:: Validar DLL
if not exist "%CURDIR%%DLL%" (
    echo ❌ ERROR: No se encontró %DLL% en la carpeta actual.
    pause
    exit /b 1
)

:: (opcional) desbloquear DLL si fue descargada
powershell -NoProfile -Command "try{Unblock-File -Path '%CURDIR%%DLL%'}catch{}" 1>nul 2>nul

set "OK32=SKIP"
set "OK64=SKIP"

echo ✅ Registrando en 32 bits...
if exist "%REGASM32%" (
    "%REGASM32%" "%CURDIR%%DLL%" /codebase /tlb
    if errorlevel 1 (echo   ❌ ERROR x86 & set "OK32=ERR") else (echo   ✓ OK x86 & set "OK32=OK")
) else (
    echo   ℹ️  No se encontró RegAsm x86, se omite.
)

echo.
echo ✅ Registrando en 64 bits...
if exist "%REGASM64%" (
    "%REGASM64%" "%CURDIR%%DLL%" /codebase /tlb
    if errorlevel 1 (echo   ❌ ERROR x64 & set "OK64=ERR") else (echo   ✓ OK x64 & set "OK64=OK")
) else (
    echo   ℹ️  No se encontró RegAsm x64, se omite.
)

echo.
if "%OK32%"=="OK" if "%OK64%"=="OK" (
    echo ✅ Registro completado correctamente.
) else (
    echo ⚠️  Hubo errores en al menos una arquitectura. Revisa el texto anterior.
)

:fin
pause
