@echo off
setlocal enabledelayedexpansion

:: ========= UAC: auto-elevación =========
:: Si no hay privilegios de admin, se relanza con RunAs
>nul 2>&1 net session
if %errorlevel% neq 0 (
  echo Elevando privilegios...
  powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

echo.
echo ================== REGISTRO COM (regasm) ==================
echo Carpeta del script: %~dp0
cd /d "%~dp0"

:: ========= DLL objetivo =========
set "DLL=SqlHelperCom.dll"
if not "%~1"=="" set "DLL=%~1"

if not exist "%DLL%" (
  echo [ERROR] No se encontro la DLL "%DLL%" en: %cd%
  echo        Pasa el nombre por parametro o deja la DLL junto al .bat
  exit /b 1
)

:: ========= Rutas regasm v4 =========
set "REGASM32=%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\regasm.exe"
set "REGASM64=%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\regasm.exe"

if not exist "%REGASM32%" (
  echo [ERROR] No se encontro regasm 32-bit: %REGASM32%
  echo         Verifica que .NET Framework 4.x este instalado.
  exit /b 1
)

:: ========= Registrar x86 =========
set "TLB32=%~n0_x86.tlb"
echo.
echo --- Registrando x86 ---
"%REGASM32%" "%DLL%" /codebase /tlb:"%TLB32%"
if %errorlevel% equ 0 (
  echo [OK] x86 registrado. TLB: %TLB32%
) else (
  echo [ERROR] Fallo registro x86 (codigo %errorlevel%).
)

:: ========= Registrar x64 (si existe) =========
if exist "%REGASM64%" (
  set "TLB64=%~n0_x64.tlb"
  echo.
  echo --- Registrando x64 ---
  "%REGASM64%" "%DLL%" /codebase /tlb:"%TLB64%"
  if %errorlevel% equ 0 (
    echo [OK] x64 registrado. TLB: %TLB64%
  ) else (
    echo [ERROR] Fallo registro x64 (codigo %errorlevel%).
  )
) else (
  echo.
  echo [AVISO] No se encontro regasm 64-bit. Se omitio registro x64.
)

echo.
echo =============== PROCESO FINALIZADO ===============
echo Si usas Excel de 32 bits, importa x86; si usas 64 bits, x64.
echo ProgId esperado en VBA:  MiEmpresa.SqlHelper
echo.
pause
endlocal
