@echo off
title Registro de DataConnector.dll para VBA Excel
echo ============================================
echo   📦 Registro de la librería DataConnector.dll
echo ============================================
echo.

:: Carpeta actual (donde está el BAT y la DLL)
set CURDIR=%~dp0

:: Rutas de regasm para .NET Framework 4.x
set REGASM32=%windir%\Microsoft.NET\Framework\v4.0.30319\regasm.exe
set REGASM64=%windir%\Microsoft.NET\Framework64\v4.0.30319\regasm.exe

:: Nombre de la DLL a registrar
set DLL=DataConnector.dll

:: Validar existencia de la DLL
if not exist "%CURDIR%%DLL%" (
    echo ❌ ERROR: No se encontró %DLL% en la carpeta actual.
    pause
    exit /b
)

echo 🔄 Registrando en 32 bits...
"%REGASM32%" "%CURDIR%%DLL%" /codebase /tlb

echo 🔄 Registrando en 64 bits...
"%REGASM64%" "%CURDIR%%DLL%" /codebase /tlb

echo.
echo ✅ Registro completado correctamente.
pause
