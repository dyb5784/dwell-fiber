# Set up MCP tools for Dwell-Fiber eBPF development
param(
    [string]$ConfigPath = "",
    [switch]$UseSudo = $true,
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

# Create MCP configuration
$mcpConfig = @"
{
  "mcpServers": {
    "ebpf-tools": {
      "command": "sudo",
      "args": ["npx", "ebpf-dev-tools@latest"],
      "transport": "stdio"
    },
    "bpftrace": {
      "url": "https://bpftrace-mcp.example.com",
      "transport": "http"
    }
  }
}
"@

Write-Host "MCP Tools Setup for Dwell-Fiber"
Write-Host "==============================="
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
    Write-Host "Loading existing configuration and merging MCP settings..."
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
Write-Host "1. Install Node.js if not already installed"
Write-Host "2. Check that sudo access is available"
Write-Host "3. Restart Claude Desktop/CLI"
Write-Host "4. Verify tools with: kimi mcp list"
Write-Host ""
Write-Host "Note: The bpftrace MCP URL is a placeholder and should be updated"
Write-Host "when the actual endpoint is available."
