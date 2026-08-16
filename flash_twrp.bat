@echo off
REM Flash TWRP vendor_boot - Realme C53 RMX3760
REM Usage: flash_twrp.bat <slot>
set SLOT=%1
if "%SLOT%"=="" set SLOT=b
echo http ============================================
echo Flashing twrp_vendor_boot.img to vendor_boot_%SLOT%
echo ============================================
adb reboot bootloader
call :wait_fastboot
fastboot flash vendor_boot_%SLOT% twrp_vendor_boot.img
if errorlevel 1 goto :fail
echo Flashing OK. Booting recovery...
fastboot reboot recovery
goto :end

:wait_fastboot
echo Waiting for fastboot device...
fastboot getvar current-slot >nul 2>&1
if errorlevel 1 (
  timeout /t 2 /nobreak >nul
  goto :wait_fastboot
)
exit /b 0

:fail
echo FLASH GAGAL. Cek driver fastboot / koneksi USB.
exit /b 1

:end
echo Done.
exit /b 0