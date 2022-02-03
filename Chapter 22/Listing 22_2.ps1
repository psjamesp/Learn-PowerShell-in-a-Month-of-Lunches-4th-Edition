function get-LastOn {    
    <#    
    .DESCRIPTION    Tell me the most recent event log entries for logon or logoff.    
    .BUGS

    Blank 'computer' column    
    .EXAMPLE    
    get-LastOn -computername server1 | Sort-Object time -Descending |     
    Sort-Object id -unique | format-table -AutoSize -Wrap    
    ID              Domain       Computer Time                    
    --              ------       -------- ----                    
    LOCAL SERVICE   NT AUTHORITY          4/3/2020 11:16:39 AM    
    NETWORK SERVICE NT AUTHORITY          4/3/2020 11:16:39 AM    
    SYSTEM          NT AUTHORITY          4/3/2020 11:16:02 AM    
    Sorting -unique will ensure only one line per user ID, the most recent.    Needs more testing    
    .EXAMPLE    PS C:\Users\administrator> get-LastOn -computername server1 -newest 10000     
    -maxIDs 10000 | Sort-Object time -Descending |     Sort-Object id -unique | format-table -AutoSize -Wrap    
    ID              Domain       Computer Time    
    --              ------       -------- ----    
    Administrator   USS                   4/11/2020 10:44:57 PM    
    ANONYMOUS LOGON NT AUTHORITY          4/3/2020 8:19:07 AM    
    LOCAL SERVICE   NT AUTHORITY          10/19/2019 10:17:22 AM    
    NETWORK SERVICE NT AUTHORITY          4/4/2020 8:24:09 AM    
    student         WIN7                  4/11/2020 4:16:55 PM    
    SYSTEM          NT AUTHORITY          10/18/2019 7:53:56 PM    
    USSDC$          USS                   4/11/2020 9:38:05 AM    
    WIN7$           USS                   10/19/2019 3:25:30 AM    
    PS C:\Users\administrator>    
    .EXAMPLE    get-LastOn -newest 1000 -maxIDs 20     
    Only examines the last 1000 lines of the event log    
    .EXAMPLE    get-LastOn -computername server1| Sort-Object time -Descending |     
    Sort-Object id -unique | format-table -AutoSize -Wrap    
    #>    
    param (            
        [string]$ComputerName = 'localhost',            
        [int]$MaxEvents = 5000,            
        [int]$maxIDs = 5,            
        [int]$logonEventNum = 4624,            
        [int]$logoffEventNum = 4647        
    )        
    $eventsAndIDs = Get-WinEvent -LogName security -MaxEvents $MaxEvents -ComputerName $ComputerName |         
    Where-Object { $_.id -eq $logonEventNum -or $_.instanceid -eq $logoffEventNum } |         
    Select-Object -Last $maxIDs -Property TimeCreated, MachineName, Message        
    foreach ($event in $eventsAndIDs) {            
        $id = ($event |             
            parseEventLogMessage |             
            where-Object { $_.fieldName -eq "Account Name" }  |             
            Select-Object -last 1).fieldValue            
        $domain = ($event |             
            parseEventLogMessage |             
            where-Object { $_.fieldName -eq "Account Domain" }  |             
            Select-Object -last 1).fieldValue            
        $props = @{'Time' = $event.TimeCreated;
            'Computer'    = $ComputerName;                
            'ID'          = $id                
            'Domain'      = $domain
        }            
        $output_obj = New-Object -TypeName PSObject -Property $props            
        write-output $output_obj        
    }      
}    
function parseEventLogMessage() {        
    [CmdletBinding()]        
    param (            
        [parameter(ValueFromPipeline = $True, Mandatory = $True)]            
        [string]$Message         
    )            $eachLineArray = $Message -split "`n"        
    foreach ($oneLine in $eachLineArray) {            
        write-verbose "line:_$oneLine_"            
        $fieldName, $fieldValue = $oneLine -split ":", 2                
        try {
            $fieldName = $fieldName.trim()                     
            $fieldValue = $fieldValue.trim()                 
        }                
        catch {                    
            $fieldName = ""                
        }                
        if ($fieldName -ne "" -and $fieldValue -ne "" ) {                
            $props = @{'fieldName' = "$fieldName";                        
                'fieldValue'       = $fieldValue
            }                
            $output_obj = New-Object -TypeName PSObject -Property $props               
            Write-Output $output_obj                
        }        
    }    
}
Get-LastOn