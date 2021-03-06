$CakeVersion = "0.28.1"

# Make sure tools folder exists
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$ToolPath = Join-Path $PSScriptRoot "tools"
if (!(Test-Path $ToolPath)) {
    Write-Verbose "Creating tools directory..."
    New-Item -Path $ToolPath -Type directory | out-null
}

###########################################################################
# INSTALL CAKE
###########################################################################

Add-Type -AssemblyName System.IO.Compression.FileSystem
Function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}


# Make sure Cake has been installed.
$CakePath = Join-Path $ToolPath "Cake.$CakeVersion"
$CakeExePath = Join-Path $CakePath "Cake.exe"
$CakeZipPath = Join-Path $ToolPath "Cake.zip"
if (!(Test-Path $CakeExePath)) {
    Write-Host "Installing Cake $CakeVersion..."
     (New-Object System.Net.WebClient).DownloadFile("https://www.nuget.org/api/v2/package/Cake/$CakeVersion", $CakeZipPath)
     Unzip $CakeZipPath $CakePath
     Remove-Item $CakeZipPath
}

###########################################################################
# RUN BUILD SCRIPT
###########################################################################
& "$CakeExePath" ./build.cake --bootstrap
if ($LASTEXITCODE -eq 0)
{
    & "$CakeExePath" ./build.cake $args
}
exit $LASTEXITCODE