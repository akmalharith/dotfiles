#Requires -RunAsAdministrator
# Run this for the first time you load Windows to make sure WSL2 can be safely setup

# Install custom fonts
echo "Install fonts"
$fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)

if (Test-Path -Path "fonts") {
    Get-ChildItem ".\fonts\*" -Include "*.otf", "*.ttf" | 
    
    Foreach-Object {
        if (-not(Test-Path -Path "C:\Windows\fonts\$fileName" )) {
            dir $file | %{ $fonts.CopyHere($_.fullname) }
        }
    }

    cp *.otf "C:\Windows\fonts\"
    cp *.ttf "C:\Windows\fonts\"
}

# Install Chocolatey
If((Get-ExecutionPolicy) -eq "Restricted"){
    Set-ExecutionPolicy AllSigned
}

if(-not(powershell choco -v -Erroraction Ignore)){
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# List choco packages
$choco_packages = @(
    "vscode",
    "microsoft-windows-terminal"
)

$choco_packages.ForEach({
    choco install $_ -y
})

# Setup WSL2 
# WSL2 
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Update WSL2 kernel 
# Download MSI
Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -Outfile C:\Temp\wsl_update_x64.msi

# Update the kernel
msiexec.exe /I C:\Temp\wsl_update_x64.msi /quiet /qn

# Remove the installer
rm C:\Temp\wsl_update_x64.msi

# Set default version
wsl --set-default-version 2