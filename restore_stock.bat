@echo off
REM Restore stock vendor_boot (A+B) - Realme C53 RMX3760
REM place stock vendor_boot_a.img & vendor_boot_b.img in this folder
REM Usage: restore_stock.bat
echo ============================================
echo Restoring stock vendor_boot_a/b
echo ============================================
if not exist vendor_boot_a.img goto :missing
if not exist vendor_boot_b.img goto :missing
adb reboot bootloader
call :wait_fastboot
fastboot flash vendor_boot_a vendor_boot_a.img
fastboot flash vendor_boot_b vendor_boot_b.img
echo OK. Booting system...
fastboot reboot
goto :end

:wait_fastboot
fastboot getvar current-slot >nul 2>&1
if errorlevel 1 (
  timeout /t 2 /nobreak >nul
  goto :wait_fastboot
)
exit /b 0

:missing
echo ERROR: vendor_boot_a.img / vendor_boot_b.img tidak ada di folder ini.
exit /b 1

:end
echo Done.
exit /b 0