
$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = ''
$url64 = 'https://protonvpn.com/download/ProtonVPN_v5.1.8_x64.exe'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE'
  url            = $url
  url64bit       = $url64

  softwareName   = 'protonvpn*'

  checksum       = ''
  checksumType   = 'sha256'
  checksum64     = 'C7E9D52FD4D3B65FF8EA83C24DBBE3F4AD9B3726739CF645CE15B9E24EDC4AA4'
  checksumType64 = 'sha256'

  silentArgs     = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs

















