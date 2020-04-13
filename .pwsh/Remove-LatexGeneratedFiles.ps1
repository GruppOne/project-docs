#Requires -PSEdition Core
[CmdletBinding()]
param (
  # search files in this path
  [Parameter(Position = 0)]
  [System.IO.DirectoryInfo]
  $Path = (Get-Item "."),
  [switch]
  $RemovePdfs
)

$auxFilesFound = Get-ChildItem -Recurse -File -Include @(
  # if ($RemovePdfs) {
  #   "*.pdf"
  # }
  "*.aux"
  "*.log"
  "*.lof"
  "*.lot"
  "*.out"
  "*.toc"
  "*.synctex.gz"
  "*.synctex(busy)"
  "*plantuml.latex"
  "*plantuml.txt"
  "__latexindent_temp.tex"
)

$pdfsFound = @()

if ($RemovePdfs) {
  $pdfsFound = Get-ChildItem -Recurse -File -Include "*.pdf" |
    Where-Object FullName -NotMatch "\.releases"

  Write-Output "found $($pdfsFound.Count) pdfs"
}

$foldersFound = Get-ChildItem -Directory -Recurse -Include @(
  "_minted-*"
)

$diagramsFoldersFound = Get-ChildItem -Directory -Recurse -Include "img" |
  Where-Object { (Split-Path -Parent $_) -match "diagrams" }

Write-Output "found $($auxFilesFound.count) auxiliary files and $($foldersFound.count) folders"

if ($pdfsFound) {
  Remove-Item -Verbose $pdfsFound
}

if ($auxFilesFound) {
  Remove-Item -Verbose $auxFilesFound
}

if ($foldersFound) {
  Remove-Item -Recurse -Verbose $foldersFound
}

if ($diagramsFoldersFound) {
  Remove-Item -Recurse -Verbose $diagramsFoldersFound
}

# Get-ChildItem -Recurse -Directory -LiteralPath $Path |
#   Where-Object { -not $_.GetFiles("*", "AllDirectories") } |
#   Remove-Item -Recurse
