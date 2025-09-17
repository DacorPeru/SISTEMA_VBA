@echo off
chcp 65001 >nul
title Registrar SecureDbConnector para VBA (COM)
echo ============================================
echo 🔐 Registro de SecureDbConnector para VBA/COM
echo ============================================
echo.

:: Requiere ejecutar como Administrador
:: Ruta actual
set "CURDIR=%~dp0"

:: Rutas de regasm .NET Framework 4.x
set "REGASM32=%windir%\Microsoft.NET\Framework\v4.0.30319\regasm.exe"
set "REGASM64=%windir%\Microsoft.NET\Framework64\v4.0.30319\regasm.exe"

:: ***** NOMBRE REAL DE TU DLL *****
set "DLL=SecureDbConnector.dll"

if not exist "%CURDIR%%DLL%" (
  echo ❌ ERROR: No se encontró "%DLL%" en: %CURDIR%
  echo Archivos encontrados:
  dir /b "%CURDIR%*.dll"
  pause
  exit /b 1
)

echo ✅ Registrando en 32 bits...
"%REGASM32%" "%CURDIR%%DLL%" /codebase /tlb /nologo
echo.

echo ✅ Registrando en 64 bits...
"%REGASM64%" "%CURDIR%%DLL%" /codebase /tlb /nologo
echo.

echo ============================================
echo 🎯 Proceso finalizado. Si no hubo errores,
echo ya puedes usarlo desde VBA como referencia COM.
echo ============================================
pause
