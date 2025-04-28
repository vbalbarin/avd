[CmdletBinding(SupportsShouldProcess = $false)]
param(
    [Parameter(Mandatory)]
    [string] $StorageAccountConnectionString,
    [Parameter()]
    [string] $ExcludeLocalUserAccountName = ''    
)

# List the scripts to be executed and their parameters
$scriptList = @(
    @{ Script = 'Set-FSLogixConfiguration.ps1'; Parameters = @{ StorageAccountConnectionString = $StorageAccountConnectionString; ExcludeLocalUserAccountName = $ExcludeLocalUserAccountName } }
    @{ Script = 'Install-PowerStigModules.ps1'; Parameters = @{ AutoInstallDependencies = $true } }
)

foreach ($script in $scriptList) {
    $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath $script.Script
    # Explicit splatting doesn't work with an object value, so reference it as a local variable
    $scriptParams = $script.Parameters

    if (Test-Path -Path $scriptPath) {
        try {
            Write-Host "Executing script: $($script.Script)"
            & $scriptPath @scriptParams
        }
        catch {
            Write-Error $_.Exception -Message "Error executing script: $($script.Script)" -Category InvalidOperation -TargetObject $script
        }
    }
    else {
        Write-Error "Script not found: $scriptPath" -Category InvalidArgument
    }
}