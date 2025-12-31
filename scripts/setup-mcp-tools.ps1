#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Set up MCP tools for Dwell-Fiber eBPF development
.DESCRIPTION
    Configures MCP (Model Context Protocol) tools for eBPF compilation,
    verification, and debugging with Claude Desktop/CLI.
    
    Tools configured:
    - ebpf-tools: eBPF compilation and verification (stdio transport)
    - bpftrace: eBPF program analysis and debugging (http transport)
    
    Note: The bpftrace MCP server URL is a placeholder and should be updated
    with the actual endpoint when available.
.PARAMETER ConfigPath
    Path to Claude Desktop configuration file. Defaults to:
    - Windows: $env:APPDATA\Claude\claude_desktop_config.json
    - macOS: ~/Library/Application Support/Claude/claude_desktop_config.json
    - Linux: ~/.config/Claude/claude_desktop_config.json
.PARAMETER UseSudo
    Use sudo for the ebpf-tools command (required for privileged eBPF operations)
.PARAMETER DryRun
    Show what would be done without making changes
.EXAMPLE
    .\setup-mcp-tools.ps1
    
    Set up MCP tools using default configuration path
.EXAMPLE
    .\setup-mcp-tools.ps1 -DryRun
    
    Preview the configuration changes without applying them
.EXAMPLE
    .\setup-mcp-tools.ps1 -ConfigPath "$env:APPDATA\Claude\claude_desktop_config.json" -UseSudo
    
    Use a custom configuration file path
#>

param(
    [string]$ConfigPath = "",
    [switch]$UseSudo = $true,
    [switch]$DryRun
)

# Enhanced PowerShell detection
$script:PowerShellCmd = ""
function Get-PowerShellCommand {
    if ($script:PowerShellCmd) { return $script:PowerShellCmd }
    
    # Check for PowerShell 7+ first
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwsh) {
        $script:PowerShellCmd = $pwsh.Source
        return $script:PowerShellCmd
    }
    
    # Fall back to Windows PowerShell 5.1
    $powershell = Get-Command powershell -ErrorAction SilentlyContinue
    if ($powershell) {
        $script:PowerShellCmd = $powershell.Source
        return $script:PowerShellCmd
    }
    
    throw "No PowerShell installation found. Please install PowerShell 7+ or Windows PowerShell 5.1."
}

# Determine default config path if not specified
if ([string]::IsNullOrEmpty($ConfigPath)) {
    if ($env:APPDATA) {
        $ConfigPath = "$env:APPDATA\Claude\claude_desktop_config.json"
    } elseif ($IsMacOS) {
        $ConfigPath = "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
    } elseif ($IsLinux) {
        $ConfigPath = "$HOME/.config/Claude/claude_desktop_config.json"
    } else {
        Write-Error "Unable to determine configuration directory. Please specify -ConfigPath manually."
        exit 1
    }
}

# Create MCP configuration
$mcpConfig = @{"mcpServers" = @{
    "ebpf-tools" = @{
        "command" = if ($UseSudo) { "sudo" } else { "npx" }
        "args" = if ($UseSudo) { @("npx", "ebpf-dev-tools@latest") } else { @("ebpf-dev-tools@latest") }
        "transport" = "stdio"
    }
    "bpftrace" = @{
        "url" = "https://bpftrace-mcp.example.com"
        "transport" = "http"
    }
}}

$PowerShellExec = Get-PowerShellCommand
$PowerShellName = Split-Path $PowerShellExec -Leaf

Write-Host "MCP Tools Setup for Dwell-Fiber" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Using PowerShell: $PowerShellExec ($PowerShellName)" -ForegroundColor Gray
Write-Host "Configuration will be written to: $ConfigPath" -ForegroundColor Gray
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN - No changes will be made" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "The following configuration would be added:" -ForegroundColor Cyan
    $mcpConfig | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor White
    Write-Host ""
    Write-Host "[Dry Run] No changes made. Run without -DryRun to apply changes." -ForegroundColor Yellow
    exit 0
}

# Create directory if needed
$configDir = Split-Path $ConfigPath -Parent
if (-not (Test-Path $configDir)) {
    Write-Host "Creating configuration directory: $configDir" -ForegroundColor Green
    New-Item -Path $configDir -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path $ConfigPath)) {
    Write-Host "Creating new configuration file..." -ForegroundColor Green
    $mcpConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath -Encoding UTF8
    Write-Host "✓ Created configuration file" -ForegroundColor Green
} else {
    Write-Host "Loading existing configuration and merging MCP settings..." -ForegroundColor Gray
    try {
        $existing = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        
        if (-not $existing.PSObject.Properties['mcpServers']) {
            $existing | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue ([PSCustomObject]@{}) -Force
        }

        foreach ($server in $mcpConfig.mcpServers.Keys) {
            if ($existing.mcpServers.PSObject.Properties[$server]) {
                $existing.mcpServers.$server = $mcpConfig.mcpServers[$server]
            } else {
                $existing.mcpServers | Add-Member -NotePropertyName $server -NotePropertyValue $mcpConfig.mcpServers[$server]
            }
            Write-Host "✓ Added/updated server: $server" -ForegroundColor Green
        }
        
        $existing | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath -Encoding UTF8
        Write-Host "✓ Merged configuration into $ConfigPath" -ForegroundColor Green
    } catch {
        Write-Error "Failed to merge configuration: $_"
        Write-Warning "Backing up existing config to $ConfigPath.backup"
        Copy-Item $ConfigPath "$ConfigPath.backup" -Force
        Write-Host "Creating fresh configuration file..." -ForegroundColor Yellow
        $mcpConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath -Encoding UTF8
        exit 1
    }
}

Write-Host ""
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "✓ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Using: $PowerShellName" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Install Node.js if not already installed" -ForegroundColor Gray
if ($PowerShellName -eq "pwsh") { Write-Host "   (PowerShell 7+ detected)" -ForegroundColor Green }
Write-Host "2. Check that sudo access is available" -ForegroundColor Gray
Write-Host "3. Restart Claude Desktop/CLI to load MCP tools" -ForegroundColor Gray
Write-Host "4. Verify tools with: kimi mcp list" -ForegroundColor Gray
Write-Host ""
if ($PowerShellName -eq "powershell") {
    Write-Host "Note: Using Windows PowerShell 5.1. Consider upgrading to PowerShell 7+ for better performance." -ForegroundColor Yellow
}
Write-Host "Note: bpftrace MCP URL is a placeholder and should be updated" -ForegroundColor Yellow
Write-Host "      when the actual endpoint is available." -ForegroundColor Yellow
