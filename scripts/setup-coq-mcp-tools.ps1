#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Set up Coq proof assistant MCP tools for Dwell-Fiber development
.DESCRIPTION
    Configures MCP tools for Coq proof assistant integration and mathematical proof validation
    
    Tools configured:
    - coq-assistant: Coq proof assistant integration via coq-mcp-server
    - proof-validator: Mathematical proof checking service
    
    Note: proof-validator URL is a placeholder and should be updated when actual service is available
.PARAMETER ConfigPath
    Path to Claude configuration file
.PARAMETER DryRun
    Show what would be done without making changes
#>

param(
    [string]$ConfigPath = "",
    [switch]$DryRun
)

# Determine default config path if not specified
if ([string]::IsNullOrEmpty($ConfigPath)) {
    if ($env:APPDATA) {
        $ConfigPath = "$env:APPDATA\Claude\claude_desktop_config.json"
    } else {
        Write-Error "Unable to determine configuration directory. Please specify -ConfigPath manually."
        exit 1
    }
}

# Coq MCP configuration
$mcpConfig = @"
{
  "mcpServers": {
    "coq-assistant": {
      "command": "npx",
      "args": ["coq-mcp-server@latest"],
      "transport": "stdio"
    },
    "proof-validator": {
      "url": "https://proof-checker.mcp.io",
      "transport": "http"
    }
  }
}
"@

Write-Host "Coq MCP Tools Setup for Dwell-Fiber"
Write-Host "===================================="
Write-Host ""
Write-Host "Configuration will be written to: $ConfigPath"
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN - No changes will be made"
    Write-Host ""
    Write-Host "The following configuration would be added:"
    Write-Host $mcpConfig
    exit 0
}

# Create directory if needed
$configDir = Split-Path $ConfigPath -Parent
if (-not (Test-Path $configDir)) {
    Write-Host "Creating configuration directory: $configDir"
    New-Item -Path $configDir -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path $ConfigPath)) {
    Write-Host "Creating new configuration file..."
    $mcpConfig | Out-File -FilePath $ConfigPath -Encoding UTF8
} else {
    Write-Host "Loading existing configuration and merging Coq MCP settings..."
    try {
        # Read existing config
        $existing = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        
        # Add mcpServers if not exists
        if (-not $existing.PSObject.Properties['mcpServers']) {
            Add-Member -InputObject $existing -MemberType NoteProperty -Name "mcpServers" -Value ([PSObject]::new())
        }
        
        # Merge new MCP servers
        $mcp = $mcpConfig | ConvertFrom-Json
        foreach ($server in $mcp.mcpServers.PSObject.Properties) {
            Add-Member -InputObject $existing.mcpServers -MemberType NoteProperty -Name $server.Name -Value $server.Value -Force
        }
        
        # Write back
        $existing | ConvertTo-Json -Depth 10 | Out-File -FilePath $ConfigPath -Encoding UTF8
    } catch {
        Write-Error "Failed to merge configuration: $_"
        Write-Host "Consider backing up and recreating: $ConfigPath.backup"
        exit 1
    }
}

Write-Host ""
Write-Host "Setup complete!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Install coq-mcp-server if not already available: npm install -g coq-mcp-server"
Write-Host "2. Restart Claude Desktop/CLI to load the new MCP tools"
Write-Host "3. Verify tools work: kimi mcp list"
Write-Host ""
Write-Host "Note: proof-validator URL is a placeholder and should be updated"
Write-Host "when the actual proof checking service is available."
