param ([string]$origProject)

$VCPKG_HASH = "294f76666c3000630d828703e675814c05a4fd43"
$TDLIB_HASH = "51743dfd01dff6179e2d8f7095729caa4e2222e9"

# Save orig PATH to restore at the end
$OrigPATH = $env:PATH
# Change to exist MSVS path
$MSVC_HOME = "D:\Programs\Microsoft Visual Studio\2022\Community"

Write-Host "[I] Building TDLib" -ForegroundColor Green
git clone https://github.com/tdlib/td.git .\tools\td

$CurrDir = $PSScriptRoot + "\tools\td"
Set-Location $CurrDir

if (Test-Path $CurrDir\vcpkg){
      Write-Host "[I] TDLib VCPKG package already exist" -ForegroundColor Green
}
else {
      Write-Host "[W] TDLib VCPKG package doesn't exist, downloading..." -ForegroundColor DarkYellow
      git clone https://github.com/microsoft/vcpkg.git .\vcpkg
      .\vcpkg\bootstrap-vcpkg.bat
      Write-Host "[I] TDLib VCPKG package successfully installed!" -ForegroundColor Green
}

$VCPKG_PATH = $CurrDir + "\vcpkg"
$TARGET_PLATFORM = "x64"
$env:PATH += ";$VCPKG_PATH;"

if (Select-String -Path "$VCPKG_PATH\triplets\$TARGET_PLATFORM-windows-static.cmake" -SimpleMatch -Pattern "set(VCPKG_BUILD_TYPE release)"){
      Write-Host "[I] TDLib VCPKG already patched" -ForegroundColor Green
}
else {
      Write-Host "[W] Patching TDLib VCPKG..." -ForegroundColor DarkYellow
      Add-Content -Path "$VCPKG_PATH\triplets\$TARGET_PLATFORM-windows-static.cmake" -Value "set(VCPKG_BUILD_TYPE release)"
      Write-Host "[I] TDLib VCPKG successfuly patched!" -ForegroundColor Green
}

# Apply patch to force create static build of tdlib https://stackoverflow.com/questions/10113017/setting-the-msvc-runtime-in-cmake
git apply --verbose $origProject\tools\patches\tdlib-static.patch

vcpkg list
vcpkg install gperf:x64-windows-static openssl:x64-windows-static zlib:x64-windows-static

# https://stackoverflow.com/questions/2124753/how-can-i-use-powershell-with-the-visual-studio-command-prompt
Push-Location "$MSVC_HOME\VC\Auxiliary\Build"
cmd /c "vcvarsall.bat $TARGET_PLATFORM & set" |
ForEach-Object {
  if ($_ -match "=") {
    $v = $_.split("=", 2); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])" 
  }
}
Pop-Location
Write-Host "`n[I] TDLib Visual Studio Command Prompt variables set" -ForegroundColor Yellow

Remove-Item build -Force -Recurse -ErrorAction SilentlyContinue
mkdir build
Set-Location build
cmake -A x64 -DCMAKE_INSTALL_PREFIX:PATH=../tdlib -DCMAKE_TOOLCHAIN_FILE:FILEPATH=../vcpkg/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-windows-static -DCMAKE_BUILD_TYPE=Release -DGPERF_EXECUTABLE:FILEPATH="$VCPKG_PATH\installed\x64-windows-static\tools\gperf\gperf.exe" ..
cmake --build . --target install --config Release

# Return current PATH var for current session
$env:PATH = $OrigPATH
Set-Location ..

Write-Host "[I] TDLib had successfuly build!" -ForegroundColor Green