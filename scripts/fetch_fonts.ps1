$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$logDir = Join-Path $root 'logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir 'fetch_fonts.log'
function Log($msg) {
    $line = '{0} {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $msg
    $line | Tee-Object -FilePath $log -Append
}

$families = @(
    @{ css = 'https://fonts.googleapis.com/css2?family=Cormorant:wght@600;700'; name = 'Cormorant' },
    @{ css = 'https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700'; name = 'Manrope' }
)

$fontsDir = Join-Path $root 'miras\assets\fonts'
New-Item -ItemType Directory -Force -Path $fontsDir | Out-Null
$ua = 'curl/7.64.1'
$ok = 0
$failed = @()

Log '=== fetch_fonts start ==='
foreach ($f in $families) {
    Log "CSS: $($f.css)"
    $css = $null
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            $css = Invoke-WebRequest -Uri $f.css -Headers @{ 'User-Agent' = $ua } -TimeoutSec 30 -UseBasicParsing
            break
        }
        catch {
            Log "  css attempt $attempt failed: $($_.Exception.Message)"
            if ($attempt -eq 3) { $failed += $f.name }
        }
    }
    if (-not $css) { continue }

    $seen = @{}
    foreach ($m in [regex]::Matches($css.Content, '@font-face\s*\{[^}]*\}')) {
        $b = $m.Value
        $weight = [regex]::Match($b, 'font-weight:\s*(\d+)').Groups[1].Value
        $url = [regex]::Match($b, 'url\((https://[^)]+)\)').Groups[1].Value
        if (-not $weight -or -not $url -or $seen.ContainsKey($weight)) { continue }
        if ($url -notmatch '\.ttf(\?|$)') {
            Log "  weight ${weight}: not a TTF ($url), skip"
            continue
        }
        $seen[$weight] = $true
        $outFile = Join-Path $fontsDir "$($f.name)-$weight.ttf"
        $saved = $false
        for ($attempt = 1; $attempt -le 3; $attempt++) {
            try {
                Invoke-WebRequest -Uri $url -OutFile $outFile -TimeoutSec 60 -UseBasicParsing
                $bytes = [System.IO.File]::ReadAllBytes($outFile)
                $isTtf = ($bytes[0] -eq 0x00 -and $bytes[1] -eq 0x01) -or ($bytes[0] -eq 0x4F -and $bytes[1] -eq 0x54)
                $sizeOk = $bytes.Length -gt 20000
                if ($isTtf -and $sizeOk) {
                    Log "  OK $($f.name)-$weight.ttf ($([math]::Round($bytes.Length / 1KB)) KB)"
                    $script:ok++
                    $saved = $true
                    break
                }
                else {
                    Log "  weight ${weight}: bad file (ttf=$isTtf size=$($bytes.Length)), retry"
                    Remove-Item $outFile -ErrorAction SilentlyContinue
                }
            }
            catch {
                Log "  download attempt $attempt failed: $($_.Exception.Message)"
            }
        }
        if (-not $saved) { $failed += "$($f.name)-$weight" }
    }
}

$license = @(
    'Fonts bundled under the SIL Open Font License:',
    'Cormorant (c) Christian Thalmann, github.com/google/fonts/ofl/cormorant',
    'Manrope (c) Mikhail Sharanda, github.com/google/fonts/ofl/manrope',
    'License: https://openfontlicense.org/'
)
Set-Content -Path (Join-Path $fontsDir 'FONTS-LICENSE.txt') -Value $license -Encoding utf8

Log "=== fetch_fonts done: ok=$ok failed=$($failed.Count) ==="
if ($failed.Count -gt 0) {
    Log "FAILED: $($failed -join ', ')"
    exit 2
}
exit 0
