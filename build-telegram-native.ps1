# Save orig PATH to restore at the end
$OrigPATH = $env:PATH
# Change to exist MSVS path
$MSVC_HOME = "..\..\Microsoft Visual Studio\2022\Community"
$CurrDir = $PSScriptRoot

# if you already build tdlib or have system-wide version in PATH, comment line bellow
& .\build-tdlib.ps1 $CurrDir

Set-Location $CurrDir

if (Test-Path $CurrDir\tools\vcpkg){
      Write-Host "[I] VCPKG package already exist" -ForegroundColor Green
}
else {
      Write-Host "[W] VCPKG package doesn't exist, downloading..." -ForegroundColor DarkYellow
      git clone https://github.com/microsoft/vcpkg.git .\tools\vcpkg
      .\tools\vcpkg\bootstrap-vcpkg.bat
      Write-Host "[I] VCPKG package successfully installed!" -ForegroundColor Green
}

$NINJA_VERSION = "v1.12.1"
if (Test-Path $CurrDir\tools\ninja.exe){
      Write-Host "[I] Ninja builder already exist" -ForegroundColor Green
}
else{
      Write-Host "[w] Ninja builder doesn't exist, downloading..." -ForegroundColor DarkYellow
      Invoke-WebRequest "https://github.com/ninja-build/ninja/releases/download/$NINJA_VERSION/ninja-win.zip" -OutFile $CurrDir\tools\ninja-win.zip
      Expand-Archive $CurrDir\tools\ninja-win.zip $CurrDir\tools\
      Remove-Item $CurrDir\tools\ninja-win.zip
      Write-Host "[I] Ninja builder successfully installed!" -ForegroundColor Green
}

$VCPKG_PATH = $CurrDir + "\tools\vcpkg"
$TARGET_PLATFORM = "x64"
$env:PATH += "$VCPKG_PATH;$CurrDir\tools;D:\Work\Intertool\td-current\tdlib;$CurrDir\tools\td\tdlib"

if (Select-String -Path "$VCPKG_PATH\triplets\$TARGET_PLATFORM-windows-static.cmake" -SimpleMatch -Pattern "set(VCPKG_BUILD_TYPE release)"){
      Write-Host "[I] VCPKG already patched" -ForegroundColor Green
}
else {
      Write-Host "[W] Patching VCPKG..." -ForegroundColor DarkYellow
      Add-Content -Path "$VCPKG_PATH\triplets\$TARGET_PLATFORM-windows-static.cmake" -Value "set(VCPKG_BUILD_TYPE release)"
      Write-Host "[I] VCPKG successfuly patched!" -ForegroundColor Green
}

vcpkg list
& ".\install_prereq.bat" "$VCPKG_PATH" $TARGET_PLATFORM

# https://stackoverflow.com/questions/2124753/how-can-i-use-powershell-with-the-visual-studio-command-prompt
Push-Location "$MSVC_HOME\VC\Auxiliary\Build"
cmd /c "vcvarsall.bat $TARGET_PLATFORM & set" |
ForEach-Object {
  if ($_ -match "=") {
    $v = $_.split("=", 2); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])" 
  }
}
Pop-Location
Write-Host "`n[I] Visual Studio Command Prompt variables set" -ForegroundColor Yellow

Remove-Item build -Force -Recurse -ErrorAction SilentlyContinue
mkdir build
Set-Location build
cmake "-DCMAKE_TOOLCHAIN_FILE=$VCPKG_PATH\scripts\buildsystems\vcpkg.cmake" "-DVCPKG_TARGET_TRIPLET=$TARGET_PLATFORM-windows-static" "-DCMAKE_BUILD_TYPE=Release" -GNinja ..
ninja

# Return current PATH var for current session
$env:PATH = $OrigPATH
Set-Location ..