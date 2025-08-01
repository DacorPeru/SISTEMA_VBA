@echo off
echo ============================================
echo 📦 Registro de SmartValidator.dll para VBA Excel
echo ============================================
echo.

:: Obtener la carpeta actual donde está el .bat y la DLL
set CURDIR=%~dp0

:: Rutas de regasm para 32 y 64 bits (.NET Framework 4.x)
set REGASM32=%windir%\Microsoft.NET\Framework\v4.0.30319\regasm.exe
set REGASM64=%windir%\Microsoft.NET\Framework64\v4.0.30319\regasm.exe

:: Nombre de la DLL a registrar
set DLL=SmartValidator.dll

:: Verificar si la DLL existe en la carpeta actual
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
echo ✅ Proceso finalizado correctamente.
pause
