[CmdletBinding(SupportsShouldProcess = $false)]
param(
  [Parameter(Mandatory)]
  [string] $StorageAccountConnectionString,
  [Parameter()]
  [string] $LocalUserAccountName = ''
)

[string]$FSLogixKeyName = 'blobstorage'

## Configure RDP
# Add Windows Firewall rule for Shortpath
$AllowRDPShortpathFWRule = @{
  DisplayName = 'Remote Desktop - Shortpath (UDP-In)'
  Action      = 'Allow'
  Description = 'Inbound rule for the Remote Desktop service to allow RDP traffic. [UDP 3390]'
  Group       = '@FirewallAPI.dll,-28752'
  Name        = 'RemoteDesktop-UserMode-In-Shortpath-UDP'
  PolicyStore = 'PersistentStore'
  Profile     = 'Domain,Private'
  Service     = 'TermService'
  Protocol    = 'udp'
  LocalPort   = 3390
  Program     = '%SystemRoot%\system32\svchost.exe'
  Enabled     = 'true'
}
New-NetFirewallRule @AllowRDPShortpathFWRule

# Add registry keys
$WinstationsKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'
$WinStationKeyValues = (
  @{Name = 'fUseUdpPortRedirector'; PropertyType = 'dword'; Value = 1 },
  @{Name = 'UdpPortNumber'; PropertyType = 'dword'; Value = 3390 },
  @{Name = 'ICEControl'; PropertyType = 'dword'; Value = 2 }
)
$WinStationKeyValues | ForEach-Object { New-ItemProperty -Path $WinstationsKey @_ -ErrorAction SilentlyContinue -Force }

# TODO: Retrieve key using UAMI instead of passing it as a parameter

## Store Azure Storage Account connection String in Credential Manager
# https://learn.microsoft.com/fslogix/how-to-protect-connection-string
& "C:\Program Files\FSLogix\Apps\frx.exe" add-secure-key -key $FSLogixKeyName -value $StorageAccountConnectionString

## FSLogix VM configuration 
$FSLogixProfilesKey = 'HKLM:\SOFTWARE\FSLogix\Profiles'
$FSLogixProfilesKeyValues = (
  @{Name = 'CCDLocations'; PropertyType = 'multistring'; Value = ('type=azure,connectionString="|fslogix/{0}|"' -f $FSLogixKeyName) },
  @{Name = 'DeleteLocalProfileWhenVHDShouldApply'; PropertyType = 'dword'; Value = 1 },
  @{Name = 'Enabled'; PropertyType = 'dword'; Value = 1 },
  @{Name = 'FlipFlopProfileDirectoryName'; PropertyType = 'dword'; Value = 1 },
  @{Name = 'ClearCacheOnLogoff'; PropertyType = 'dword'; Value = 1 },
  @{Name = 'VolumeType'; PropertyType = 'string'; Value = 'VHDX' },
  @{Name = 'HealthyProvidersRequiredForRegister'; PropertyType = 'dword'; Value = 1 },
  @{Name = 'ProfileType'; PropertyType = 'dword'; Value = 0 }
)
$FSLogixProfilesKeyValues | ForEach-Object { New-ItemProperty -Path $FSLogixProfilesKey @_ -ErrorAction SilentlyContinue -Force }

<# If necessary
New-ItemProperty -Path $FSLogixProfilesKey -Name RedirXMLSourceFolder -PropertyType String -Value "%ProgramFiles%\FSLogix\Apps\Rules" -Force

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

if ($LocalUserAccountName) {
  Add-LocalGroupMember -Group "FSLogix Profile Exclude List" -Member $LocalUserAccountName
}