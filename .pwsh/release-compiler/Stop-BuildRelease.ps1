Get-Job "compiling latex file*" |
  Stop-Job -PassThru |
  Remove-Job
