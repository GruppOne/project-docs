#Requires -PSEdition Core
[CmdletBinding(DefaultParameterSetName = "WithFolder")]
param (
  [Parameter(Position = 0, ParameterSetName = "WithFile")]
  [System.IO.FileInfo[]]
  $files,
  [Parameter(Position = 0, ParameterSetName = "WithFolder")]
  [System.IO.DirectoryInfo]
  $folder = (Get-Location | Get-Item)
)

begin {
  [System.IO.DirectoryInfo]$startingLocation = Get-Location | Get-Item
  [System.IO.DirectoryInfo]$workspaceFolder = Get-Item $PSScriptRoot/../../
  [string]$chktexrc = Get-Item "$workspaceFolder/.chktexrc" | Select-Object -ExpandProperty FullName
}

process {
  if ($PSCmdlet.ParameterSetName -eq "WithFolder") {
    $files = Get-ChildItem $folder -Recurse -File -Include "*.tex"
  }

  foreach ($file in $files) {
    Write-Verbose "Linting $file"
    Set-Location $file.Directory
    $warnings = chktex -q -l $chktexrc $file.Name

    if ($warnings) {
      Write-Output "----------------------------------------"
      Write-Output $warnings
      Write-Output "----------------------------------------"
    }
  }
}

end {
  Set-Location $startingLocation
}
