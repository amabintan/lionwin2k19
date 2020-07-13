<# Funtion Security Options Settings Hardening Point 1.2 - 1.5 #>
function Set-SecurePolicies{
Write-Host "#----------- Process Hardening Point 1.2 - 1.5 #-----------"
secedit /configure /db %temp%\temp.sdb /cfg SecurityPolicy2019.inf
Start-Sleep -s 2
Write-Host "Finished Point 1.2 - 1.5"
}
<#  End of Function Hardening Point 1.2 - 1.5#>

<# Function for Set Registry Hardening Point 1.5#>
Function Hardening-RegistryValue([string]$point,[string]$key,[string]$name,[string]$value){
Write-Host "#----------- Process Hardening Point $point #-----------"
Write-Host "Regitry: $key"
Set-ItemProperty -Path "$key" -Name "$name" -Value "$value" -Type DWORD -ErrorAction SilentlyContinue
if($?)
{
   "command succeeded"
}
else
{
    $msg = $Error[0].Exception.Message
    "command failed : $msg"
}
Start-Sleep -s 2
Write-Host "Finished Point $point"
Write-Host ""
}
<# End of Function for Set Registry Hardening Point 1.5# #>

<# Funtion Event_Log Settings Hardening Point 1.6#>
function EventLog-Settings{
Write-Host "#----------- Process Hardening Point 1.6 #-----------"
Limit-Eventlog -Logname Application -MaximumSize 50MB -OverflowAction OverwriteAsNeeded
Limit-Eventlog -Logname Security -MaximumSize 50MB -OverflowAction OverwriteAsNeeded
Limit-Eventlog -Logname System -MaximumSize 50MB -OverflowAction OverwriteAsNeeded
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Setup"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Setup" -Name "$Maxsize" -Value "51249152" -Type DWORD -ErrorAction SilentlyContinue
Write-Host "Finished Point 1.6"
}
<#  End of Function Hardening Point 1.6#>


<# Funtion Event_Log Settings Hardening Point 1.7#>
function EventLog-Settings{
Write-Host "#----------- Process Hardening Point 1.7 #-----------"

Write-Host "Finished Point 1.7"
}
<#  End of Function Hardening Point 1.7#>

<# Main Program For Hardening#>
$data = Get-Content "data.json" | Out-String | ConvertFrom-Json
foreach ($line in $data) {
    $point = $line.point
	$key = $line.key
	$name = $line.name
	$value = $line.value

	Hardening-RegistryValue "$point" "$key" "$name" "$value"
	Write-Host "------------------ OUTPUT $point ------------------"
	Get-ItemProperty -Path "$key" -Name "$name"
	Write-Host "------------------ ############# ------------------"
}

<# Call Function EventLog-Settings  1.6 Process#>
EventLog-Settings

<# Main Program For Hardening #>



