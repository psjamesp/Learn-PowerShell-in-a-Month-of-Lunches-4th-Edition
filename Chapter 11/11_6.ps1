Get-Process | 
    Format-Table Name, @{name = 'VM(MB)'; expression = { $_.VM }; formatstring = 'F2'; align = 'right' }  -AutoSize