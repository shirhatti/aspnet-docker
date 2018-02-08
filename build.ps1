[cmdletbinding()]
param(
    [switch]$CleanupDocker
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-CleanupDocker()
{
    if ($CleanupDocker) {
        # Windows base images are large, preserve them to avoid the overhead of pulling each time.
        docker images |
        Where-Object {
            -Not ($_.StartsWith("microsoft/nanoserver ")`
            -Or $_.StartsWith("microsoft/windowsservercore ")`
            -Or $_.StartsWith("REPOSITORY ")) } |
        ForEach-Object { $_.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)[2] } |
        Select-Object -Unique |
        ForEach-Object { docker rmi -f $_ }
    }
}


function Invoke-DockerBuild()
{
    $manifest = Get-Content manifest.json | ConvertFrom-Json
    Write-Host "Building docker images for " $manifest.repositoryName
    $manifest.tags | ForEach-Object {
        Invoke-Expression ("docker build -t {0}/{1} {2}" -f $manifest.repositoryName, $_.tagName, $_.directory)
    }
}

# Invoke-CleanupDocker
Invoke-DockerBuild
