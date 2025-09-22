@echo off
setlocal enabledelayedexpansion

:: Detectar la arquitectura del sistema (32 o 64 bits)
set "ARCHITECTURE=%PROCESSOR_ARCHITECTURE%"

:: Mostrar la arquitectura del sistema
echo Arquitectura del sistema: %ARCHITECTURE%

:: Si el sistema es 64 bits
if "%ARCHITECTURE%"=="AMD64" (
    echo Sistema operativo 64 bits detectado.
    set "REGASM=%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\regasm.exe"
    set "TLB=%~n0_x64.tlb"
    echo Registrando en 64 bits...
) else (
    :: Si el sistema es 32 bits
    echo Sistema operativo 32 bits detectado.
    set "REGASM=%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\regasm.exe"
    set "TLB=%~n0_x86.tlb"
    echo Registrando en 32 bits...
)

:: Comprobar si la DLL existe
if not exist "SqlHelperCom.dll" (
    echo [ERROR] No se encontro la DLL "SqlHelperCom.dll" en: %cd%
    exit /b 1
)

:: Comprobar si regasm está presente
if not exist "%REGASM%" (
    echo [ERROR] No se encontro regasm en la ruta: %REGASM%
    exit /b 1
)

:: Registrar la DLL con regasm
echo Registrando la DLL con regasm...
"%REGASM%" "SqlHelperCom.dll" /codebase /tlb:"%TLB%"

:: Comprobar si el registro fue exitoso
if %errorlevel% equ 0 (
    echo [OK] Registro exitoso. TLB: %TLB%
) else (
    echo [ERROR] Fallo el registro de la DLL (codigo %errorlevel%).
)

echo.
pause
endlocal
