@ECHO OFF
SET DISTRO=Ubuntu

echo "Installing WSL and %DISTRO%..."
wsl --install -d %DISTRO%
echo "WSL Info:"
wsl --status
echo "%DISTRO% WSL installed!"