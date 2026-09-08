param(
    [int]$CallTimeoutSec = 110
)

$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $PSScriptRoot
$logDir = Join-Path $root 'logs'
$smokeDir = Join-Path $logDir 'smoke'
New-Item -ItemType Directory -Force -Path $smokeDir | Out-Null
$log = Join-Path $logDir 'device_smoke.log'
function Log($msg) {
    $line = '{0} {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $msg
    Add-Content -Path $log -Value $line
    Write-Host $line
}

Add-Type -AssemblyName System.Drawing
$adb = 'D:\Android\Sdk\platform-tools\adb.exe'
$apk = Join-Path $root 'miras\build\app\outputs\flutter-apk\app-debug.apk'

function Convert-DownscalePng($src, $dst, $maxSide = 1400) {
    $img = [System.Drawing.Image]::FromFile($src)
    try {
        $w = $img.Width; $h = $img.Height
        if ($w -le $maxSide -and $h -le $maxSide) {
            Copy-Item $src $dst -Force
            return
        }
        $scale = [math]::Min($maxSide / $w, $maxSide / $h)
        $bmp = New-Object System.Drawing.Bitmap([int]($w * $scale), [int]($h * $scale))
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.DrawImage($img, 0, 0, $bmp.Width, $bmp.Height)
        $g.Dispose()
        $bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
    }
    finally {
        $img.Dispose()
    }
}

function Get-UiaNode($pattern) {
    $shell = & $adb shell uiautomator dump /sdcard/miras_dump.xml 2>&1 | Out-String
    $null = & $adb pull /sdcard/miras_dump.xml (Join-Path $smokeDir 'dump.xml') 2>&1
    $raw = Get-Content (Join-Path $smokeDir 'dump.xml') -Raw
    $doc = New-Object System.Xml.XmlDocument
    $doc.LoadXml($raw)
    foreach ($node in $doc.SelectNodes('//node')) {
        $txt = [string]$node.GetAttribute('text')
        $desc = [string]$node.GetAttribute('content-desc')
        if ($txt -match $pattern -or $desc -match $pattern) {
            return [string]$node.GetAttribute('bounds')
        }
    }
    return $null
}

function Tap-ByPattern($pattern) {
    $bounds = Get-UiaNode $pattern
    if (-not $bounds) {
        Log "    uiautomator: no node matching '$pattern'"
        return $false
    }
    if ($bounds -match '\[(\d+),(\d+)\]\[(\d+),(\d+)\]') {
        $cx = ([int]$Matches[1] + [int]$Matches[3]) / 2
        $cy = ([int]$Matches[2] + [int]$Matches[4]) / 2
        $null = & $adb shell input tap ([int]$cx) ([int]$cy)
        Log "    tap '$pattern' at $([int]$cx),$([int]$cy)"
        return $true
    }
    return $false
}

function Take-Screenshot($name) {
    $null = & $adb shell screencap -p /sdcard/miras_$name.png
    $null = & $adb pull /sdcard/miras_$name.png (Join-Path $smokeDir "$name.png") 2>&1
    if (Test-Path (Join-Path $smokeDir "$name.png")) {
        Log "    screenshot $name.png saved"
        return $true
    }
    Log "    screenshot $name FAILED"
    return $false
}

function Parse-Verdict($output) {
    if ($output -match '(?m)^Error:' -or $output -match 'File not found') { return 'ERROR' }
    $lines = @($output -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
    for ($i = $lines.Count - 1; $i -ge 0; $i--) {
        $l = $lines[$i]
        if ($l.StartsWith('[')) { continue }
        if ($l -match '^(YES|ДА)\b') { return 'YES' }
        if ($l -match '^(NO|НЕТ)\b') { return 'NO' }
        if ($l -match '\b(YES|ДА)\b' -and $l -notmatch '\b(NO|НЕТ)\b') { return 'YES' }
        if ($l -match '\b(NO|НЕТ)\b') { return 'NO' }
        return 'UNPARSED::' + $l
    }
    return 'EMPTY'
}

$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'Machine')

Log '=== device_smoke start ==='
$exitCode = 0

$devices = (& $adb devices) -join ' '
if ($devices -notmatch '\bdevice\b') {
    Log "FATAL: no adb device: $devices"
    exit 4
}
Log "device ok: $((($devices -split "`n") | Where-Object { $_ -match 'device' }) -join '; ')"

if (-not (Test-Path $apk)) {
    Log "FATAL: apk not found: $apk"
    exit 4
}

Log 'installing apk...'
& $adb install -r $apk 2>&1 | ForEach-Object { Log "    $_" }
$null = & $adb logcat -c
Log 'launching app...'
$null = & $adb shell am start -n tr.miras.app/tr.miras.miras.MainActivity
Start-Sleep -Seconds 6
$null = Take-Screenshot '01_home_ru'

Log 'navigate: open gallery'
$okTap = Tap-ByPattern 'Смотреть галерею|Galeriye git|Open the gallery'
Start-Sleep -Seconds 3
$null = Take-Screenshot '02_gallery'

Log 'navigate: open Side detail'
$okTap = Tap-ByPattern '^Сиде$|^Side$'
Start-Sleep -Seconds 3
$null = Take-Screenshot '03_detail_side'

Log 'navigate: back to home'
$null = & $adb shell input keyevent 4
Start-Sleep -Seconds 1
$null = & $adb shell input keyevent 4
Start-Sleep -Seconds 2

Log 'navigate: switch language to English'
$okTap = Tap-ByPattern 'Язык|Dil|Language'
Start-Sleep -Seconds 2
$okTap = Tap-ByPattern '^English$'
Start-Sleep -Seconds 2
$null = Take-Screenshot '04_home_en'

Log 'collecting logcat...'
$mirasLines = (& $adb logcat -d) | Where-Object { $_ -match 'MIRAS' } | Select-Object -First 20
Add-Content -Path (Join-Path $smokeDir 'logcat_miras.txt') -Value ($mirasLines -join "`n")
Log "    MIRAS log lines: $(@($mirasLines).Count)"
$fullLog = (& $adb logcat -d) -join "`n"
$fatal = ($fullLog -split "`n") | Where-Object { $_ -match 'FATAL EXCEPTION|AndroidRuntime.*Process: tr.miras.app' } | Select-Object -First 5
if ($fatal) {
    Log 'CRASH DETECTED:'
    $fatal | ForEach-Object { Log "    $_" }
    $exitCode = 3
}
else {
    Log '    no crashes in logcat'
}

Log 'vision check of screenshots...'
$shots = @('01_home_ru', '02_gallery', '03_detail_side', '04_home_en')
foreach ($name in $shots) {
    $png = Join-Path $smokeDir "$name.png"
    if (-not (Test-Path $png)) {
        Log "[$name] missing screenshot"
        if ($exitCode -eq 0) { $exitCode = 2 }
        continue
    }
    $small = Join-Path $smokeDir "${name}_vision.png"
    Convert-DownscalePng $png $small
    $jsonPath = $small.Replace('\', '/')
    $json = '{"image_source":"' + $jsonPath + '","prompt":"Это скриншот мобильного приложения-гида. Проверь: заголовки и текст читаемы, вёрстка не поломана (нет наложений, обрезанного текста, пустых серых зон, сообщений об ошибках). Начни ответ строго с YES (всё хорошо) или NO (есть дефекты), затем кратко что видно на экране."}'
    $job = Start-Job -ScriptBlock {
        param($j)
        mcp-cli call zai-vision analyze_image $j 2>&1 | Out-String
    } -ArgumentList $json
    if (Wait-Job $job -Timeout $CallTimeoutSec) {
        $out = Receive-Job $job | Out-String
        Remove-Job $job -Force
        $verdict = Parse-Verdict $out
        Log "[$name] vision: $verdict"
        if ($verdict -notlike 'YES*') { if ($exitCode -eq 0) { $exitCode = 2 } }
    }
    else {
        Stop-Job $job -Force
        Remove-Job $job -Force
        Get-Process -Name mcp-cli -ErrorAction SilentlyContinue | Stop-Process -Force
        Log "[$name] vision TIMEOUT (${CallTimeoutSec}s)"
        if ($exitCode -eq 0) { $exitCode = 2 }
    }
    Start-Sleep -Seconds 1
}

Log "=== device_smoke done, exit=$exitCode ==="
exit $exitCode
