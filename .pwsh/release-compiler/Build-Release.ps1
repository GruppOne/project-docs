#Requires -PSEdition Core
[CmdletBinding()]
param (
  [String]
  $ReleaseBaseName = "GruppOne-Stalker",
  [String]
  $VersionBuildMetadata
)

try {
  java -version | Out-Null
}
catch [System.Management.Automation.CommandNotFoundException] {
  throw "java is not available on PATH"
}

if (-not $env:PLANTUML_JAR) {
  throw "environment variable PLANTUML_JAR is not set"
}

try {
  lualatex -v | Out-Null
}
catch [System.Management.Automation.CommandNotFoundException] {
  throw "lualatex is not available on PATH"
}

$lualatexCommand = {
  [CmdletBinding()]
  param(
    # LaTeX file to build
    [Parameter(Position = 0, Mandatory = $true)]
    [String]
    $sourceFilename,
    # LaTeX file to build
    [Parameter(Position = 1, Mandatory = $true)]
    [String]
    $destinationFilename
  )
  [System.IO.FileInfo]$sourceFile = Get-Item -LiteralPath $sourceFilename
  $compiledSourceFilename = $sourceFile.FullName -replace "\.tex$", ".pdf"

  Set-Location $sourceFile.Directory

  lualatex `
    --interaction=nonstopmode `
    --file-line-error `
    --shell-escape `
    $sourceFile.Name

  if ($LASTEXITCODE) {
    Write-Error "something went wrong while compiling $($sourceFile) "
  }

  if (-not (Test-Path $compiledSourceFilename)) {
    throw "no output produced"
  }

  lualatex `
    --interaction=nonstopmode `
    --file-line-error `
    --shell-escape `
    $sourceFile.Name

  $compiledSource = Get-Item -LiteralPath $compiledSourceFilename
  Copy-Item -Force $compiledSource $destinationFilename
}

Write-Output "building PlantUML diagrams"

$rawOut = java -jar ${env:PLANTUML_JAR} `
  -progress `
  -failfast `
  -checkmetadata `
  -charset "UTF-8" `
  -x "**/commons/style/*.pu" `
  -o "img" `
  "**/diagrams/*.pu"

Write-Output "`n--------------------------"

if ($LASTEXITCODE -and $rawOut -notmatch "No diagram found") {
  throw "something went wrong while exporting UML diagrams"
}

$productVersion = (
  Get-Item -LiteralPath "commons/template.tex" |
    Select-String -Pattern "^\\setVersione{\d+\.\d+\.\d+}$" |
    Select-Object -ExpandProperty Line
) -replace "^\\setVersione{" -replace "}$"

if (-not $productVersion) {
  throw "Product version was not found"
}

$ReleaseName = $ReleaseBaseName + "_" + "$productVersion"
if ($VersionBuildMetadata) {
  $ReleaseName += "+" + $VersionBuildMetadata
}

$OutputBaseDirectory = "$(Get-Location)/.releases/$ReleaseName"

if (-not (Test-Path $OutputBaseDirectory)) {
  Write-Output "created destination folder $OutputBaseDirectory"
  New-Item -ItemType Directory $OutputBaseDirectory

  New-Item -ItemType Directory "$OutputBaseDirectory/esterni"
  New-Item -ItemType Directory "$OutputBaseDirectory/esterni/verbali"
  New-Item -ItemType Directory "$OutputBaseDirectory/interni"
  New-Item -ItemType Directory "$OutputBaseDirectory/interni/verbali"
}

# this is horrible
$documents = @(
  [PSCustomObject]@{
    SourceFile  = Get-Item "esterni/analisi-dei-requisiti/analisi-dei-requisiti.tex"
    Destination = [IO.Path]::Combine($OutputBaseDirectory, "esterni", "analisi-dei-requisiti_v$productVersion.pdf")
  },
  [PSCustomObject]@{
    SourceFile  = Get-Item "esterni/glossario/glossario.tex"
    Destination = [IO.Path]::Combine($OutputBaseDirectory, "esterni", "glossario_v$productVersion.pdf")
  },
  [PSCustomObject]@{
    SourceFile  = Get-Item "esterni/manuale-manutentore/manuale-manutentore.tex"
    Destination = [IO.Path]::Combine($OutputBaseDirectory, "esterni", "manuale-manutentore_v$productVersion.pdf")
  },
  [PSCustomObject]@{
    SourceFile  = Get-Item "esterni/manuale-utente/manuale-utente.tex"
    Destination = [IO.Path]::Combine($OutputBaseDirectory, "esterni", "manuale-utente_v$productVersion.pdf")
  },
  [PSCustomObject]@{
    SourceFile  = Get-Item "esterni/piano-di-progetto/piano-di-progetto.tex"
    Destination = [IO.Path]::Combine($OutputBaseDirectory, "esterni", "piano-di-progetto_v$productVersion.pdf")
  },
  [PSCustomObject]@{
    SourceFile  = Get-Item "esterni/piano-di-qualifica/piano-di-qualifica.tex"
    Destination = [IO.Path]::Combine($OutputBaseDirectory, "esterni", "piano-di-qualifica_v$productVersion.pdf")
  },
  [PSCustomObject]@{
    SourceFile  = Get-Item "interni/norme-di-progetto/norme-di-progetto.tex"
    Destination = [IO.Path]::Combine($OutputBaseDirectory, "interni", "norme-di-progetto_v$productVersion.pdf")
  },
  # [PSCustomObject]@{
  #   SourceFile  = Get-Item "interni/studio-di-fattibilita/studio-di-fattibilita.tex"
  #   Destination = [IO.Path]::Combine($OutputBaseDirectory, "interni", "studio-di-fattibilita_v$productVersion.pdf")
  # },
  [PSCustomObject]@{
    SourceFile  = Get-Item "lettera-di-presentazione/lettera-di-presentazione.tex"
    Destination = [IO.Path]::Combine($OutputBaseDirectory, "lettera-di-presentazione.pdf")
  }
)

$meetingNotes = Get-ChildItem -Path "esterni/verbali", "interni/verbali" -File -Recurse |
  Where-Object Name -match "verbale-(esterno|interno)_\d{4}-\d{2}-\d{2}\.tex" | ForEach-Object {

    $extOrInt = $_ | Split-Path -Parent | Split-Path -Parent | Split-Path -Leaf

    return [PSCustomObject]@{
      SourceFile  = $_
      Destination = [IO.Path]::Combine($OutputBaseDirectory, $extOrInt, "verbali", ($_.Name -replace "\.tex", ".pdf"))
    }
  }

$allDocuments = $documents + $meetingNotes

Write-Output "Found $($documents.Length) documents and $($meetingNotes.Length) meeting notes"
Write-Output "Current product version is $productVersion"

$build = $allDocuments | ForEach-Object {
  $jobArguments = [ordered]@{
    Name         = "compiling latex file $($_.SourceFile.Name)"
    ScriptBlock  = $lualatexCommand
    ArgumentList = @(
      $_.SourceFile.FullName
      $_.Destination
    )
  }

  Start-Job @jobArguments
}

$build.Name

Receive-Job -Wait -AutoRemoveJob $build | Out-Null

## This section allows to exit gracefully, terminating incomplete jobs

# # Change the default behavior of CTRL-C so that the script can intercept and use it versus just terminating the script.
# [Console]::TreatControlCAsInput = $True
# # Sleep for 1 second and then flush the key buffer so any previously pressed keys are discarded and the loop can monitor for the use of CTRL-C. The sleep command ensures the buffer flushes correctly.
# Start-Sleep -Seconds 1
# $Host.UI.RawUI.FlushInputBuffer()

# # Continue to loop while there running jobs.
# While ((Get-Job $build | Where-Object State -Match Running)) {
#   # If a key was pressed during the loop execution, check to see if it was CTRL-C (aka "3"), and if so exit the script after clearing out any running jobs and setting CTRL-C back to normal.
#   If ($Host.UI.RawUI.KeyAvailable -and ($Key = $Host.UI.RawUI.ReadKey("AllowCtrlC,NoEcho,IncludeKeyUp"))) {
#     If ([Int]$Key.Character -eq 3) {
#       Write-Host ""
#       Write-Warning "CTRL-C was used - Shutting down any running jobs before exiting the script."
#       Remove-Job $build -Force -Confirm:$False

#       [Console]::TreatControlCAsInput = $False
#       _Exit-Script -HardExit $True
#     }

#     # Flush the key buffer again for the next loop.
#     $Host.UI.RawUI.FlushInputBuffer()
#   }

#   # Perform other work here such as process pending jobs or process out current jobs.
# }
