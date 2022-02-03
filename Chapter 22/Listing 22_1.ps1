<#
.Synopsis   Checks if computer account exists for computer names provided
.DESCRIPTION   Checks if computer account exists for computer names provided
.EXAMPLE   Get-ADExistence $computers
.EXAMPLE   Get-ADExistence "computer1","computer2"
#>
function Get-ADExistence {
    [CmdletBinding()]    
    Param(        
        # single or array of machine names        
        [Parameter(Mandatory = $true,                   
            ValueFromPipeline = $true,                   
            ValueFromPipelineByPropertyName = $true,                   
            HelpMessage = "Enter one or multiple computer names")]        
        [String[]]$Computers     )    
    Begin {}    
    Process {        
        foreach ($computer in $computers) {            
            try {                
                $comp = get-adcomputer $computer -ErrorAction stop                
                $properties = @{computername = $computer                                
                    Enabled                  = $comp.enabled                                
                    InAD                     = 'Yes'
                }            
            }
            catch {                
                $properties = @{computername = $computer                                
                    Enabled                  = 'Fat Chance'                                
                    InAD                     = 'No'
                }            
            }             
            finally {                
                $obj = New-Object -TypeName psobject -Property $properties                
                Write-Output $obj            
            }        
        } #End foreach    
    } #End Process    
    End {}
} #End Function