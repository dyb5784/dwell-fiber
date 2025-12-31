#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Verify MCP tools setup for Dwell-Fiber eBPF development
.DESCRIPTION
    Checks the status of MCP configuration, prerequisites, and tools
.PARAMETER ConfigPath
    Path to Claude configuration file
#>

param(
    [string]$ConfigPath = "$env:APPDATA\Claude\claude_desktop_config.json"
)

Write-Host "MCP Setup Verification for Dwell-Fiber"
Write-Host "======================================"
Write-Host ""

# Check configuration file
Write-Host "1. Configuration File:" -ForegroundColor Cyan
if (Test-Path $ConfigPath) {
    Write-Host "   ✓ Found: $ConfigPath" -ForegroundColor Green
    try {
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        Write-Host "   ✓ Valid JSON" -ForegroundColor Green
        
        if ($config.mcpServers) {
            Write-Host "   ✓ MCP servers configured:" -ForegroundColor Green
            foreach ($server in $config.mcpServers.PSObject.Properties) {
                Write-Host "     - $($server.Name): $($server.Value.transport) transport" -ForegroundColor Gray
            }
        } else {
            Write-Host "   ✗ No MCP servers found" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ✗ Invalid JSON: $_" -ForegroundColor Red
    }
} else {
    Write-Host "   ✗ Not found: $ConfigPath" -ForegroundColor Red
}
Write-Host ""

# Check prerequisites
Write-Host "2. Prerequisites:" -ForegroundColor Cyan

# Check Node.js/npx
$npx = Get-Command npx -ErrorAction SilentlyContinue
if ($npx) {
    Write-Host "   ✓ npx found: $($npx.Source)" -ForegroundColor Green
    
    # Try to get Node.js version
    try {
        $nodeVersion = node --version 2>$null
        Write-Host "   ✓ Node.js version: $nodeVersion" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠ Node.js: Installed but version check failed" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ✗ npx not found - Install Node.js from https://nodejs.org" -ForegroundColor Red
}

# Check sudo access
if ($IsWindows) {
    Write-Host "   ! sudo: Using Windows administrator privileges" -ForegroundColor Gray
} else {
    $sudo = Get-Command sudo -ErrorAction SilentlyContinue
    if ($sudo) {
        Write-Host "   ✓ sudo found: $($sudo.Source)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ sudo not found - May need root access for eBPF" -ForegroundColor Yellow
    }
}

# Check bpftrace
$bpftrace = Get-Command bpftrace -ErrorAction SilentlyContinue
if ($bpftrace) {
    Write-Host "   ✓ bpftrace found: $($bpftrace.Source)" -ForegroundColor Green
} else {
    Write-Host "   ⚠ bpftrace not found - Optional, for eBPF debugging only" -ForegroundColor Yellow
}
Write-Host ""

# Check eBPF program
Write-Host "3. eBPF Program:" -ForegroundColor Cyan
$bpfFile = "bpf\dwell_monitor.bpf.c"
if (Test-Path $bpfFile) {
    Write-Host "   ✓ Main eBPF program found: $bpfFile" -ForegroundColor Green
    
    # Check if it loads tracepoints/kprobes
    $content = Get-Content $bpfFile -Raw
    if ($content -match 'SEC\("tracepoint') {
        Write-Host "   ✓ Uses tracepoints for kernel instrumentation" -ForegroundColor Green
    }
    if ($content -match 'SEC\("kprobe') {
        Write-Host "   ✓ Uses kprobes for kernel function hooking" -ForegroundColor Green
    }
} else {
    Write-Host "   ✗ eBPF program not found: $bpfFile" -ForegroundColor Red
}
Write-Host ""

# Summary
Write-Host "4. Summary:" -ForegroundColor Cyan
$green = [System.ConsoleColor]::Green
$yellow = [System.ConsoleColor]::Yellow
$red = [System.ConsoleColor]::Red

Write-Host ""
Write-Host "   Configuration: " -NoNewline
if (Test-Path $ConfigPath) {
    Write-Host "✓ Ready" -ForegroundColor $green
} else {
    Write-Host "✗ Missing" -ForegroundColor $red
}

Write-Host "   Prerequisites: " -NoNewline
if ($npx) {
    Write-Host "✓ Core tools installed" -ForegroundColor $green
} else {
    Write-Host "✗ Missing Node.js" -ForegroundColor $red
}

Write-Host "   bpftrace tool: " -NoNewline
if ($bpftrace) {
    Write-Host "✓ Available" -ForegroundColor $green
} else {
    Write-Host "⚠ Optional (not installed)" -ForegroundColor $yellow
}

Write-Host ""
Write-Host "=" -ForegroundColor Gray
Write-Host ""

# Next steps
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Restart Claude Desktop/CLI to load the MCP tools" -ForegroundColor Gray
Write-Host "2. Verify tools work: kimi mcp list" -ForegroundColor Gray
Write-Host "3. If bpftrace needed, install from: https://bpftrace.org" -ForegroundColor Gray
Write-Host ""
Write-Host "Testing commands:" -ForegroundColor Gray
Write-Host "   kimi 'Compile the eBPF program in bpf/dwell_monitor.bpf.c'" -ForegroundColor DarkGray
Write-Host "   kimi 'Verify eBPF bytecode passes kernel safety checks'" -ForegroundColor DarkGray
Write-Host "   kimi 'Help debug the dwell_tracker map logic'" -ForegroundColor DarkGray
