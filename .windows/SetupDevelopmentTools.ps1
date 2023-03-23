# Run this for the first time you load Windows to make sure WSL2 can be safely setup

If((Get-ExecutionPolicy) -eq "Restricted"){
    Set-ExecutionPolicy AllSigned
}

if(-not(powershell choco -v -Erroraction Ignore)){
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# choco packages
$choco_packages = @(
    "vscode"
    "microsoft-windows-terminal"
    "firacode"
)

$choco_packages.ForEach({
    choco install $_ -y
})

# WSL2 configurations
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -Outfile C:\Temp\wsl_update_x64.msi
C:\Temp\wsl_update_x64.msi /quiet /qn
wsl --set-default-version 2
