@echo off
echo ========================================
echo Updating AndroidManifest.xml
echo ========================================
echo.

powershell -Command "(Get-Content 'android\app\src\main\AndroidManifest.xml') -replace '@android:mipmap/sym_def_app_icon', '@mipmap/ic_launcher' | Set-Content 'android\app\src\main\AndroidManifest.xml'"

echo AndroidManifest.xml updated to use custom icon!
echo.
echo Now rebuilding app...
flutter clean
flutter pub get
echo.
echo Ready to run! Execute: flutter run
echo.
pause
