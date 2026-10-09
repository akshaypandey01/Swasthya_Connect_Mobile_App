@echo off
echo ========================================
echo SwasthyaConnect App Icon Setup
echo ========================================
echo.

echo Step 1: Generating app icons from logo...
echo This will create all required icon sizes.
echo.
dart run flutter_launcher_icons
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Icon generation failed!
    echo Make sure Flutter and Dart are in your PATH.
    pause
    exit /b 1
)

echo.
echo ========================================
echo SUCCESS! Icons generated.
echo ========================================
echo.
echo Now updating AndroidManifest.xml to use the new icons...
echo.

echo Step 2: Cleaning build...
flutter clean

echo.
echo Step 3: Getting dependencies...
flutter pub get

echo.
echo ========================================
echo SETUP COMPLETE!
echo ========================================
echo.
echo Next steps:
echo 1. Uninstall the old app from your device/emulator
echo 2. Run: flutter run
echo 3. Check the app icon - it should now show the SwasthyaConnect logo!
echo.
pause
