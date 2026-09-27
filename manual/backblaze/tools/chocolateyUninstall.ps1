$ErrorActionPreference = 'Stop'
$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  softwareName  = 'Backblaze'
  fileType      = 'EXE'
  silentArgs   = '' # there unfortunately isn't a setting for a silent uninstall
  validExitCodes= @(0)
}

# Settings
# -h generates help message
# -version prints out the version of bzdoinstall
# -version_to_file <fname> puts version in the file
# -unzip <zipFileName> unzip this file
# -douninstall uninstalls the product
# -doinstall <dir_containing_files_to_install> [-nogui]

# Get package parameters
$pp = Get-PackageParameters
if ($null -eq $pp -or $pp.Count -eq 0) {
  # Work around for choco#1479 https://github.com/chocolatey/choco/issues/1479
  $toolsPath = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
  $paramsFile = Join-Path (Split-Path -Parent $toolsPath) 'PackageParameters.xml'
  if (Test-Path -Path $paramsFile) {
    Write-Debug "Loading package parameters from $paramsFile"
    $pp = Import-Clixml -Path $paramsFile
  } else {
    Write-Debug "No package parameters available; shims and desktop shortcut won't be removed if they were created"
    $pp = @{}
  }
}

[array]$key = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']

if ($key.Count -eq 1) {
  $key | % {
    $packageArgs['file'] = "$($_.UninstallString)"
    if ($packageArgs['fileType'] -eq 'MSI') {
      $packageArgs['silentArgs'] = "$($_.PSChildName) $($packageArgs['silentArgs'])"
      $packageArgs['file'] = ''
    } else {
	  $packageArgs['file'] = "$($_.UninstallString)"
	  $fileStringSplit = $packageArgs['file'] -split '\s+(?=(?:[^"]|"[^"]*")*$)'
	  if ($fileStringSplit.Count -gt 1) {
		  $packageArgs['file'] = $fileStringSplit[0]
		  $packageArgs['silentArgs'] += " $($fileStringSplit[1..($fileStringSplit.Count-1)])"
	  }
	}
	#Thanks to dtgm and the GitHub package for ideas.
	$scriptPath = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
	$ahkFile = Join-Path $scriptPath "uninstall.ahk"
	$ahkRun = "$Env:Temp\$(Get-Random).ahk"

	Copy-Item $ahkFile "$ahkRun" -Force
	$ahkProc = Start-Process -FilePath 'AutoHotKey' `
					   -ArgumentList $ahkRun `
					   -PassThru
	Write-Debug "$ahkRun start time:`t$($ahkProc.StartTime.ToShortTimeString())"
	Write-Debug "$ahkRun process ID:`t$($ahkProc.Id)"
    Uninstall-ChocolateyPackage @packageArgs
	Remove-Item "$ahkRun" -Force
  }
} elseif ($key.Count -eq 0) {
  Write-Warning "$packageName has already been uninstalled by other means."
} elseif ($key.Count -gt 1) {
  Write-Warning "$($key.Count) matches found!"
  Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
  Write-Warning "Please alert package maintainer the following keys were matched:"
  $key | % {Write-Warning "- $($_.DisplayName)"}
}

if ($pp.DesktopShortcut) {
  $desktop = [System.Environment]::GetFolderPath("Desktop")
  Remove-Item "$desktop\Backblaze Control Panel.lnk" -ErrorAction SilentlyContinue -Force | Out-Null
}
Remove-Item "C:\Program Files\Backblaze" -ErrorAction SilentlyContinue -Force | Out-Null