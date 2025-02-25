# Add registry keys
$WinstationsKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'
New-ItemProperty -Path $WinstationsKey -Name 'fUseUdpPortRedirector' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 1 -Force
New-ItemProperty -Path $WinstationsKey -Name 'UdpPortNumber' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 3390 -Force
New-ItemProperty -Path $WinstationsKey -Name 'ICEControl' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 2 -Force



# Add windows firewall rule for shortpath RDP
New-NetFirewallRule -DisplayName 'Remote Desktop - Shortpath (UDP-In)' `
   -Action Allow `
   -Description 'Inbound rule for the Remote Desktop service to allow RDP traffic. [UDP 3390]' `
   -Group '@FirewallAPI.dll,-28752' `
   -Name 'RemoteDesktop-UserMode-In-Shortpath-UDP' `
   -PolicyStore PersistentStore `
   -Profile Domain, Private `
   -Service TermService `
   -Protocol udp `
   -LocalPort 3390 `
   -Program '%SystemRoot%\system32\svchost.exe' `
   -Enabled:True

 
# FSLogix VM configuration 
$FSLogix = 'HKLM:\SOFTWARE\FSLogix\Profiles'
<#--------------------------------------------------------------------------------------------------------------------------------------------------------
 Modify this line below with your connection string located on your storage account under Security + networking-->Access keys-->Connection string
--------------------------------------------------------------------------------------------------------------------------------------------------------#>
New-ItemProperty -Path $FSLogix -Name CCDLocations -PropertyType multistring -Value ('type=azure,connectionString="YOUR CONNECTION STRING"') -Force
#--------------------------------------------------------------------------------------------------------------------------------------------------------
New-ItemProperty -Path $FSLogix -Name DeleteLocalProfileWhenVHDShouldApply -PropertyType DWord -Value "1" -Force
New-ItemProperty -Path $FSLogix -Name Enabled -PropertyType DWord -Value "1" -Force
New-ItemProperty -Path $FSLogix -Name FlipFlopProfileDirectoryName -PropertyType DWord -Value "1" -Force
New-ItemProperty -Path $FSLogix -Name ClearCacheOnLogoff -PropertyType DWord -Value "1"
New-ItemProperty -Path $FSLogix -Name VolumeType -PropertyType String -Value "VHDX"
New-ItemProperty -Path $FSLogix -Name HealthyProvidersRequiredForRegister -PropertyType DWord -Value "1"
New-ItemProperty -Path $FSLogix -Name ProfileType -PropertyType DWord -Value "0"


<# If necessary
New-ItemProperty -Path $FSLogix -Name RedirXMLSourceFolder -PropertyType String -Value "%ProgramFiles%\FSLogix\Apps\Rules" -Force

$Redirections = @'
<Redirections>
  <Redirection>
    <Folder>LocalAppData\Microsoft\Credentials</Folder>
  </Redirection>
  <Redirection>
    <Folder>LocalAppData\Microsoft\Vault</Folder>
  </Redirection>
  <!-- Add any other custom folders you wish to redirect here -->
</Redirections>
'@

$Redirections | Set-Content "C:\Users\james.sterling\OneDrive - DODEA\Scripts\VDI\Redirections.xml"
#>
