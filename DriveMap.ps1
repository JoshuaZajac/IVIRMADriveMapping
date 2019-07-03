Start-Transcript -Path $(Join-Path $env:temp "DriveMapping.log")

$driveMappingConfig=@()


######################################################################
#                section script configuration                        #
######################################################################

<#
   Add your internal Active Directory Domain name and custom network drives below
#>

$dnsDomainName= "RMANAS02.rmanj.com"

$driveMappingConfig+= [PSCUSTOMOBJECT]@{
    DriveLetter = "H"
    UNCPath= "\\RMANAS02\Private\$env:USERNAME"
    Description="Home"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "S"
    UNCPath= "\\RMANAS02\Shared"
    Description="Shared"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "M"
    UNCPath= "\\RMANAS02\Scanner"
    Description="Scanner"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "L"
    UNCPath= "\\RMANAS02\Lanfax"
    Description="LanFax"
}

######################################################################
#               end section script configuration                     #
######################################################################

$connected=$false
$retries=0
$maxRetries=3

Write-Output "Starting script..."
do {
    
    if (Resolve-DnsName $dnsDomainName -ErrorAction SilentlyContinue){
    
        $connected=$true

    } else{
 
        $retries++
        
        Write-Warning "Cannot resolve: $dnsDomainName, assuming no connection to fileserver"
 
        Start-Sleep -Seconds 3
 
        if ($retries -eq $maxRetries){
            
            Throw "Exceeded maximum numbers of retries ($maxRetries) to resolve dns name ($dnsDomainName)"
        }
    }
 
}while( -not ($Connected))

#Map drives
    $Drives=Get-PSDrive

    $driveMappingConfig.GetEnumerator() | ForEach-Object {
        
        If(!($Drives.Name -contains $PSItem.DriveLetter)) {
            
        If($Null -eq $Creds){ $Creds = Get-Credential -Credential "RMANJ\$env:USERNAME"}

        Write-Output "Mapping network drive $($PSItem.UNCPath)"

        New-PSDrive -PSProvider FileSystem -Name $PSItem.DriveLetter -Root $PSItem.UNCPath -Description $PSItem.Description -Scope global -Credential $Creds

        (New-Object -ComObject Shell.Application).NameSpace("$($PSItem.DriveLEtter):").Self.Name=$PSItem.Description

        }
}

Stop-Transcript