$ErrorActionPreference = 'Stop';

$packageArgs = @{
  packageName    = 'protondrive'
  fileType       = 'exe'
  url            = 'https://proton.me/download/drive/windows/3.0.8/x64/Proton%20Drive%20Setup%203.0.8.exe'
  silentArgs     = '-s'
  validExitCodes = @(0)
  softwareName   = 'ProtonDrive*'
  checksum       = 'EE9E1BEA23CAFF07F8A0C27DE54579718DC3C74E5C1FDF6A48EE37BD3C27EC16'
  checksumType   = 'sha256'
}
Install-ChocolateyPackage @packageArgs
