Start-Transcript -Path $(Join-Path $env:temp "InstallArtemis.log")

$dnsDomainName="RMAMDT.rmanj.com"

$retries=0
$maxRetries=3

Write-Output "Starting script..."
    
    if (Resolve-DnsName $dnsDomainName -ErrorAction SilentlyContinue){
    
        Write-Host "Copying installer.."
        Copy-Item -Path "\\rmamdt.rmanj.com\PDQ_Repository\Artemis\Artemis_Installer_prod_64bit_20170916" -Destination C:\bin\Artemis -Recurse
        cd "C:\bin\Artemis\"
        Write-Host "Installing..."
        (Start-Process -FilePath "install.exe" -ArgumentList "Y prod Y" -Wait -PassThru -Verb RunAs).ExitCode
        cd "C:\"
        Write-Host "Cleaning up..."
        Remove-Item -Path "C:\bin\Artemis" -Force -Recurse

    } else{
 
        $retries++
        
        Write-Warning "Cannot resolve: $dnsDomainName, assuming no connection to fileserver"
 
        Start-Sleep -Seconds 3
 
        if ($retries -eq $maxRetries){
            
            Throw "Exceeded maximum numbers of retries ($maxRetries) to resolve dns name ($dnsDomainName)"
        }
    }

Stop-Transcript