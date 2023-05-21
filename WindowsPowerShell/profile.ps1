# Set-Proxy command
Function SetProxy() {
    Param(
        $Addr = $null,
        [switch]$ApplyToSystem
    )
    
    $env:HTTP_PROXY = $Addr;
    $env:HTTPS_PROXY = $Addr; 
    $env:http_proxy = $Addr;
    $env:https_proxy = $Addr;
  
    if ($addr -eq $null) {
        [Net.WebRequest]::DefaultWebProxy = New-Object Net.WebProxy;
        if ($ApplyToSystem) { SetSystemProxy $null; }
        Write-Output "Successful unset all proxy variable";
    }
    else {
        [Net.WebRequest]::DefaultWebProxy = New-Object Net.WebProxy $Addr;
        if ($ApplyToSystem) {
            $matchedResult = ValidHttpProxyFormat $Addr;
            # Matched result: [URL Without Protocol][Input String]
            if (-not ($matchedResult -eq $null)) {
                SetSystemProxy $matchedResult.1;
            }
        }
        Write-Output "Successful set proxy as $Addr";
    }
}
Function SetSystemProxy($Addr = $null) {
    Write-Output $Addr
    $proxyReg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings";

    if ($Addr -eq $null) {
        Set-ItemProperty -Path $proxyReg -Name ProxyEnable -Value 0;
        return;
    }
    Set-ItemProperty -Path $proxyReg -Name ProxyServer -Value $Addr;
    Set-ItemProperty -Path $proxyReg -Name ProxyEnable -Value 1;
}
Function ValidHttpProxyFormat ($Addr) {
    $regex = "(?:https?:\/\/)(\w+(?:.\w+)*(?::\d+)?)";
    $result = $Addr -match $regex;
    if ($result -eq $false) {
        throw [System.ArgumentException]"The input $Addr is not a valid HTTP proxy URI.";
    }

    return $Matches;
}
Set-Alias set-proxy SetProxy
