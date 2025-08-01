@echo off
echo ============================================
echo 🔐 Registro de HashLib.dll para VBA Excel
echo ============================================
echo.

:: Obtener la carpeta actual
set CURDIR=%~dp0

:: Rutas de regasm de .NET Framework 4.x (32 y 64 bits)
set REGASM32=%windir%\Microsoft.NET\Framework\v4.0.30319\regasm.exe
set REGASM64=%windir%\Microsoft.NET\Framework64\v4.0.30319\regasm.exe

:: Nombre de la DLL
set DLL=HashLib.dll

:: Comprobar si la DLL existe
if not exist "%CURDIR%%DLL%" (
    echo ❌ ERROR: No se encontró %DLL% en la carpeta actual.
    pause
    exit /b
)

echo ✅ Registrando en 32 bits...
"%REGASM32%" "%CURDIR%%DLL%" /codebase /tlb

echo ✅ Registrando en 64 bits...
"%REGASM64%" "%CURDIR%%DLL%" /codebase /tlb

echo.
echo ✅ Registro completado correctamente.
pause
