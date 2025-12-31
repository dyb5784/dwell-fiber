<#
.SYNOPSIS
  Strip Coq sources to signature-only snippets for Claude tier-0 index.
.DESCRIPTION
  Walks .\ (recursively), keeps Lemma/Theorem/Remark name + type +
  2-line proof sketch, dumps everything to coq-signatures.md.
#>

$outFile = "coq-signatures.md"
$maxProofLines = 2          # how many lines of proof body to keep
$maxSnippet  = 5            # total lines per entry (header + body)

Write-Host "Indexing Coq files..." -ForegroundColor Cyan
Set-Content -Path $outFile -Value "# Coq Signature Index`n" -Encoding utf8

Get-ChildItem -Recurse -Filter *.v | ForEach-Object {
    $lines   = Get-Content $_.FullName -Encoding UTF8
    $inProof = $false
    $proofBuf= @()
    $snip    = @()

    foreach ($l in $lines) {
        # detect start of statement
        if ($l -match '^\s*(Lemma|Theorem|Remark|Corollary|Fact)\s+(\w+)') {
            if ($snip.Count -gt 0) {                       # flush previous
                $snip + "`n" | Add-Content -Path $outFile -Encoding utf8
            }
            $snip    = @("### $($matches[2])`n", "$l`n")
            $inProof = $false
            $proofBuf= @()
            continue
        }

        # grab first few lines of proof
        if ($l -match '^\s*Proof\s*\.' -or $l -match '^\s*Next\s*Obligation') {
            $inProof = $true
        }
        if ($inProof -and $proofBuf.Count -lt $maxProofLines) {
            $proofBuf += "$l`n"
        }
        if ($l -match '^\s*(Qed|Defined|Admitted)\s*\.' -and $snip.Count -gt 0) {
            $snip += $proofBuf
            $inProof = $false
        }

        # safety valve: never exceed maxSnippet
        if ($snip.Count -ge $maxSnippet) {
            $snip += "`n"
            $snip | Add-Content -Path $outFile -Encoding utf8
            $snip = @()
        }
    }
    # flush last one if any
    if ($snip.Count -gt 0) {
        $snip + "`n" | Add-Content -Path $outFile -Encoding utf8
    }
}

Write-Host "Done → $outFile" -ForegroundColor Green
