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

$PowerShellExec = Get-PowerShellCommand
$PowerShellName = Split-Path $PowerShellExec -Leaf

Write-Host "MCP Setup Verification for Dwell-Fiber" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Using PowerShell: $PowerShellExec ($PowerShellName)" -ForegroundColor Gray
Write-Host "Configuration: $ConfigPath" -ForegroundColor Gray
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

if ($PowerShellName -eq "pwsh") {
    Write-Host "   ✓ PowerShell 7+ detected" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Using Windows PowerShell 5.1 (functional but older)" -ForegroundColor Yellow
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

Write-Host "   PowerShell: " -NoNewline
if ($PowerShellName -eq "pwsh") {
    Write-Host "✓ PowerShell 7+" -ForegroundColor Green
} else {
    Write-Host "⚠ Windows PowerShell 5.1" -ForegroundColor Yellow
}

Write-Host "   Configuration: " -NoNewline
if (Test-Path $ConfigPath) {
    Write-Host "✓ Ready" -ForegroundColor Green
} else {
    Write-Host "✗ Missing" -ForegroundColor Red
}

Write-Host "   Prerequisites: " -NoNewline
if ($npx) {
    Write-Host "✓ Core tools installed" -ForegroundColor Green
} else {
    Write-Host "✗ Missing Node.js" -ForegroundColor Red
}

Write-Host "   bpftrace tool: " -NoNewline
if ($bpftrace) {
    Write-Host "✓ Available" -ForegroundColor Green
} else {
    Write-Host "⚠ Optional (not installed)" -ForegroundColor Yellow
}

Write-Host "   eBPF Program: " -NoNewline
if (Test-Path $bpfFile) {
    Write-Host "✓ Ready" -ForegroundColor Green
} else {
    Write-Host "✗ Missing" -ForegroundColor Red
}

Write-Host ""
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Restart Claude Desktop/CLI to load the MCP tools" -ForegroundColor Gray
Write-Host "2. Verify tools work: kimi mcp list" -ForegroundColor Gray
Write-Host "3. If bpftrace needed, install from: https://bpftrace.org" -ForegroundColor Gray
Write-Host ""
Write-Host "Testing commands:" -ForegroundColor Cyan
Write-Host "   kimi 'Compile the eBPF program in bpf/dwell_monitor.bpf.c'" -ForegroundColor Gray
Write-Host "   kimi 'Verify eBPF bytecode passes kernel safety checks'" -ForegroundColor Gray
Write-Host "   kimi 'Help debug the dwell_tracker map logic'" -ForegroundColor Gray
Write-Host ""

if ($PowerShellName -eq "powershell") {
    Write-Host "Note: You have PowerShell 7+ available on this system." -ForegroundColor Yellow
    Write-Host "      Consider running these scripts with 'pwsh' for better performance." -ForegroundColor Yellow
    Write-Host "      Example: pwsh -File .\scripts\setup-mcp-tools.ps1" -ForegroundColor Yellow
    Write-Host ""
}
