# SPDX-FileCopyrightText: 2023 yuzu Emulator Project
# SPDX-License-Identifier: GPL-3.0-or-later

$ErrorActionPreference = "Stop"

$OpenSSLVer = "3_5_2"
$ExeFile = "Win64OpenSSL-$OpenSSLVer.exe"
$Uri = "https://slproweb.com/download/$ExeFile"
$Destination = "./$ExeFile"

echo "Downloading OpenSSL $OpenSSLVer from $Uri"
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($Uri, $Destination)
echo "Finished downloading $ExeFile"

$Arguments = "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-"

echo "Installing OpenSSL $OpenSSLVer"
$InstallProcess = Start-Process -FilePath $Destination -NoNewWindow -PassThru -Wait -ArgumentList $Arguments
$ExitCode = $InstallProcess.ExitCode

if ($ExitCode -ne 0) {
    echo "Error installing OpenSSL $OpenSSLVer (Error: $ExitCode)"
    Exit $ExitCode
}

echo "Finished installing OpenSSL $OpenSSLVer"

if ("$env:GITHUB_ACTIONS" -eq "true") {
    echo "OPENSSL_ROOT_DIR=C:/Program Files/OpenSSL-Win64" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
}
