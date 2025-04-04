# Source: https://github.com/Azure/ato-toolkit/blob/master/stig/windows/RequiredModules.ps1

function Get-RequiredModules {
    return @(
        @{ModuleName = 'AuditPolicyDsc'; ModuleVersion = '1.4.0.0' },
        @{ModuleName = 'AuditSystemDsc'; ModuleVersion = '1.1.0' },
        @{ModuleName = 'AccessControlDsc'; ModuleVersion = '1.4.1' },
        @{ModuleName = 'CertificateDsc'; ModuleVersion = '5.0.0' },
        @{ModuleName = 'ComputerManagementDsc'; ModuleVersion = '8.4.0' },
        @{ModuleName = 'FileContentDsc'; ModuleVersion = '1.3.0.151' },
        @{ModuleName = 'GPRegistryPolicyDsc'; ModuleVersion = '1.2.0' },
        @{ModuleName = 'nx'; ModuleVersion = '1.0' }
        @{ModuleName = 'PSDscResources'; ModuleVersion = '2.12.0.0' },
        @{ModuleName = 'SecurityPolicyDsc'; ModuleVersion = '2.10.0.0' },
        @{ModuleName = 'SqlServerDsc'; ModuleVersion = '13.3.0' },
        @{ModuleName = 'WindowsDefenderDsc'; ModuleVersion = '2.1.0' },
        @{ModuleName = 'xDnsServer'; ModuleVersion = '1.16.0.0' },
        @{ModuleName = 'xWebAdministration'; ModuleVersion = '3.2.0' },
        @{ModuleName = 'PowerSTIG'; ModuleVersion = '4.16.0' }
    )
}