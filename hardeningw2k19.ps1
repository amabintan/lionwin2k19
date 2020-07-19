<# -------------------- Funtion Prereq User -------------------- #>
function Write-ProgressHelper([int]$step,[string]$message) {
for ($i = 1; $i -le $step; $i++ )
{
    Write-Progress -Activity "$message" -Status "$i% Complete:" -PercentComplete (($i / $step)*100);
}
Write-Progress  -Activity "$message" -Completed
}

function SetupGroupUser{
Write-Host "#----------- Process Hardening [Point 1.9] -----------#"
New-LocalUser "yyyadmin" -NoPassword -FullName "Secondary Administrator" -Description "Secondary Administrator"
New-LocalUser "drctrlid" -NoPassword -FullName "DR Alternate Administrator" -Description "DR Alternate Administrator"
New-LocalUser "CLIUSR" -NoPassword -FullName "CLI User" -Description "CLI User"
Add-LocalGroupMember -Group "Administrators" -Member "yyyadmin", "drctrlid"
New-LocalGroup -Name "Allow Logon Users"
New-LocalGroup -Name "Allow Terminal Users"
New-LocalGroup -Name "Deny Logon Users"

Disable-LocalUser -Name "ocbc-guest"
Start-Sleep -s 2
Write-Host "Finished [Point 1.9]"
}
<# -------------------- Funtion Prereq User -------------------- #>

<# -------------------- Funtion Security Options Settings Hardening Point 1.2 - 1.5 -------------------- #>
function Set-SecurePolicies{
Write-Host "#----------- Process Hardening [Point 1.2 - 1.5] -----------#"
Write-Host "Apply Security Policies"
Write-ProgressHelper "50" "Applying Security Policies"
secedit /configure /db tmp\temp.sdb /cfg etc/SecurityPolicy2019.inf
Start-Sleep -s 2
Write-Host "Apply Security Policies Completed"

Write-Host "Apply Audit Policies"
Write-ProgressHelper "50" "Applying Audit Policies"
Copy-Item "etc\AuditPolicy.csv" -Destination "C:\Windows\System32\GroupPolicy\Machine\Microsoft\Windows NT\Audit\audit.csv"
Copy-Item "etc\AuditPolicy.csv" -Destination "C:\Windows\security\audit\audit.csv"
auditpol /restore /file:C:\Windows\security\audit\audit.csv
Start-Sleep -s 2
Write-Host "Apply Security Policies Completed"

Write-Host "Finished [Point 1.2 - 1.5]"
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}
<# -------------------- End of Function Hardening Point 1.2 - 1.5 -------------------- #>

<# -------------------- Function for Set Registry Hardening Point 1.5 -------------------- #>
Function Hardening-RegistryValue([string]$point,[string]$key,[string]$name,[string]$value){
Write-Host "#----------- Process Hardening [Point $point] -----------#"
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
Write-Host "Finished [Point $point]"
Write-Host ""
}
<# -------------------- End of Function for Set Registry Hardening Point 1.5 -------------------- #>

<# -------------------- Funtion Event_Log Settings Hardening Point 1.6 -------------------- #>
function EventLog-Settings{
Write-Host "#----------- Process Hardening [Point 1.6] -----------#"
Limit-Eventlog -Logname Application -MaximumSize 50MB -OverflowAction OverwriteAsNeeded
Limit-Eventlog -Logname Security -MaximumSize 50MB -OverflowAction OverwriteAsNeeded
Limit-Eventlog -Logname System -MaximumSize 50MB -OverflowAction OverwriteAsNeeded
if(Test-Path -path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Setup"){
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Setup" -Name "Maxsize" -Value "51249152" -Type DWORD -ErrorAction SilentlyContinue
}else{
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Setup"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Setup" -Name "Maxsize" -Value "51249152" -Type DWORD -ErrorAction SilentlyContinue
}
Write-Host "Finished [Point 1.6]"
}
<# -------------------- End of Function Hardening Point 1.6 -------------------- #>

<# -------------------- Funtion Services Hardening Point 1.7 -------------------- #>
function Services-Settings{
Write-Host "#----------- Process Hardening [Point 1.7] -----------#"

Write-Host "Starting Trigger Execution"
start-process "etc/trigger.bat"
if($?)
{
   "command succeeded"
}
else
{
    $msg = $Error[0].Exception.Message
    "command failed : $msg"
}

$ExceptionPoint = @("1.7_178","1.7_148","1.7_147","1.7_125","1.7_23","1.7_21","1.7_14")

$services = Get-Content "json/Services.json" | Out-String | ConvertFrom-Json
foreach ($record in $services) {
    $point = $record.point
	$name = $record.name
	$startup = $record.startup
	$stop = $record.stop
	
	if ($ExceptionPoint -Contains $point){
	Write-Host "#----------- Process Hardening Point $point #-----------"
		Write-Host "Process Skipped"
	Write-Host "#-------------------------------------------------------"
	} else{
	Write-Host "#----------- Process Hardening Point $point #-----------"
	Set-Service -Name "$name" -StartupType "$startup" -ErrorAction SilentlyContinue
    if($?)
    {
      Write-Host "command succeeded"
    }
    else
    {
       Write-Host "command Skipped"
    }
	

	Write-Host "------------------ OUTPUT $point ------------------"
	Get-Service -Name "$name" | Select-Object -Property DisplayName, Status, StartType 
	Start-Sleep -s 1
	}
}

Write-Host "Finished [Point 1.7]"
}
<# -------------------- End of Function Hardening Point 1.7 -------------------- #>

<# -------------------- Funtion Event_Log Settings Hardening Point 1.10 - 1.11 --------------------#>
function Setup-PostRegistry{
Write-Host "#----------- Process Hardening [Point 1.10 - 1.11]#-----------"

$Cekpath = @("HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0", "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0", "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0", "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1","HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2","HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56$([char]0x2215)56","HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\NULL","HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40$([char]0x2215)128","HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 56$([char]0x2215)128","HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40$([char]0x2215)128","HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56$([char]0x2215)128","HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64$([char]0x2215)128","HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128$([char]0x2215)128","HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168")

$ChipherPoints = @("1.10_17a","1.10_17c","1.10_17d","1.10_17e","1.10_17f","1.10_17g","1.10_17h","1.10_17i")

foreach ($item in $Cekpath) {
   if(Test-Path -path "$item"){
		<# nothing to do#>
   }else{
		Write-Host "item = $item"
		New-Item -Path "$item"
   }
}


$Postregistry = Get-Content "json/Registry.json" | Out-String | ConvertFrom-Json
foreach ($line in $PostRegistry) {
    $PRpoint = $line.point
	$PRkey = $line.key
	$PRname = $line.name
	$PRvalue = $line.value
	Write-Host "------------------ Processs $PRpoint ------------------"
	
	if($ChipherPoints -Contains $PRpoint){
		Write-Host "Block If == $PRkey"
		 New-ItemProperty -Path "$PRkey" -Name "$PRname" -Value "$PRvalue" -PropertyType DWORD -ErrorAction SilentlyContinue
		if($?){ 
		"command succeeded"
		}else {
				$msg = $Error[0].Exception.Message
				"command failed : $msg"
			}
	}
	else{
	
		if($PRpoint -eq "1.11_10" -or $PRpoint -eq "1.11_11" -or $PRpoint -eq "1.11_12"){
			$PRvalue = $PRvalue -as [int]
		}
		
		Set-ItemProperty -Path "$PRkey" -Name "$PRname" -Value "$PRvalue" -Type DWORD -ErrorAction SilentlyContinue
		if($?){ 
			"command succeeded"
		}else {
			$msg = $Error[0].Exception.Message
			"command failed : $msg"
		}
	}
	
	Write-Host "------------------ OUTPUT $PRpoint ------------------"
	Get-ItemProperty -Path "$PRkey" -Name "$PRname"
	Write-Host "------------------ ############# ------------------"	
} 
Write-Host "Finished [Point 1.10 & 1.11]"
}
<# -------------------- End of Function Hardening Point 1.10 - 1.11 -------------------- #>

<# -------------------- Funtion Additional Post Script --------------------#>
Function PostScript {
$PostServices = @("Windows Push Notifications User Service*","User Data Storage*","User Data Access*","Software Protection*","Contact Data*","Connected Devices Platform Service*","Connected Devices Platform User Service*")

foreach ($item in $PostServices){
	$Service = Get-Service -DisplayName "$item" | select Name
	write-host "Test: " $Service[0].Name
    $name = $Service[0].Name
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$name" -Name "Start" -Value "4" -Type DWORD -ErrorAction SilentlyContinue
    if($?)
    {
       "command succeeded"
    }
    else
    {
        $msg = $Error[0].Exception.Message
        "command failed : $msg"
    }
}
}
<# -------------------- Funtion Additional Post Script --------------------#>

<# Main Program For Hardening#>
<# Call Function EventLog-Settings  1.2 - 1.5 Process#>
Write-Host "Setup Secure Policies"
Set-SecurePolicies

$data = Get-Content "json/SecurityOptions.json" | Out-String | ConvertFrom-Json
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

<# Call Function EventLog-Settings  1.7 Process#>
Services-Settings

<# Call Function EventLog-Settings  1.8 Process#>
Write-Host "#----------- Process Hardening [Point 1.8] -----------#"
Write-Host "Skiped, Additional Service not Installed"
Write-Host "Finished [Point 1.8]"

<# Call Function EventLog-Settings  1.9 Process#>
SetupGroupUser

<# Call Function EventLog-Settings  1.10 - 1.11 Process#>
Setup-PostRegistry

<# Call Function PostScriopt #>
PostScript

<# Main Program For Hardening #>



