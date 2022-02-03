Measure-Command { Get-Content -Path vaultsToCreate.txt |   
    ForEach-Object -Parallel { Write-Output $_     Start-Sleep 1 } }



Measure-Command { Get-Content -Path vaultsToCreate.txt |   
    ForEach-Object -ThrottleLimit 100 -Parallel { Write-Output $_     Start-Sleep 1 } }