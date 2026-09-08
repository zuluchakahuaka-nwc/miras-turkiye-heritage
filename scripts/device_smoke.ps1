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
$exitCode = 0
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'Machine')

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

function Shot($name) {
    $null = & $adb shell screencap -p /sdcard/m_$name.png
    $null = & $adb pull /sdcard/m_$name.png (Join-Path $smokeDir "$name.png") 2>&1
    if (Test-Path (Join-Path $smokeDir "$name.png")) {
        Log "    screenshot $name"
        return $true
    }
    Log "    screenshot $name FAILED"
    return $false
}

function Vision-Check($name, $expectation) {
    $png = Join-Path $smokeDir "$name.png"
    if (-not (Test-Path $png)) { Log "[$name] missing"; if ($script:exitCode -eq 0) { $script:exitCode = 2 }; return }
    $small = Join-Path $smokeDir "${name}_vision.png"
    Convert-DownscalePng $png $small
    $jsonPath = $small.Replace('\', '/')
    $prompt = "Скриншот приложения MIRAS. Ожидание: $expectation. Начни ответ строго с YES (соответствует и вёрстка целая) или NO (не то или поломано), затем одна строка."
    $json = '{"image_source":"' + $jsonPath + '","prompt":"' + ($prompt -replace '"', '') + '"}'
    $job = Start-Job -ScriptBlock {
        param($j)
        mcp-cli call zai-vision analyze_image $j 2>&1 | Out-String
    } -ArgumentList $json
    if (Wait-Job $job -Timeout $CallTimeoutSec) {
        $out = Receive-Job $job | Out-String
        Remove-Job $job -Force
        $v = Parse-Verdict $out
        Log "[$name] vision: $v"
        if ($v -notlike 'YES*') { if ($script:exitCode -eq 0) { $script:exitCode = 2 } }
    }
    else {
        Stop-Job $job -Force
        Remove-Job $job -Force
        Get-Process -Name mcp-cli -ErrorAction SilentlyContinue | Stop-Process -Force
        Log "[$name] vision TIMEOUT"
        if ($script:exitCode -eq 0) { $script:exitCode = 2 }
    }
    Start-Sleep -Seconds 1
}

Log '=== device_smoke (coords mode) start ==='

$devices = (& $adb devices) -join ' '
if ($devices -notmatch '\bdevice\b') {
    Log "FATAL: no adb device"
    exit 4
}

$wake = (& $adb shell dumpsys power) | Select-String 'mWakefulness=' | Select-Object -First 1
if ($wake -match 'Asleep') {
    Log 'device asleep, waking'
    & $adb shell input keyevent 224
    Start-Sleep -Seconds 2
    & $adb shell input swipe 720 2800 720 800 300
    Start-Sleep -Seconds 2
}
$null = & $adb shell svc power stayon usb
Start-Sleep -Seconds 1
& $adb shell am force-stop tr.miras.app 2>&1 | Out-Null

Log 'installing apk...'
& $adb install -r $apk 2>&1 | ForEach-Object { Log "    $_" }
$null = & $adb logcat -c
Log 'launching app...'
$null = & $adb shell am start -n tr.miras.app/tr.miras.miras.MainActivity
Start-Sleep -Seconds 7
$null = Shot '01_home_ru'

Log 'nav: open gallery (tap CTA 720,1440)'
& $adb shell input tap 720 1440
Start-Sleep -Seconds 3
$null = Shot '02_gallery'

Log 'nav: search Side (tap 720,460, type)'
& $adb shell input tap 720 460
Start-Sleep -Seconds 1
& $adb shell input text "Side"
Start-Sleep -Seconds 2
$null = Shot '03_search_side'

Log 'nav: open card (tap 380,1150)'
& $adb shell input tap 380 1150
Start-Sleep -Seconds 3
$null = Shot '04_detail_side'

Log 'nav: back x2'
& $adb shell input keyevent 4
Start-Sleep -Seconds 1
& $adb shell input keyevent 4
Start-Sleep -Seconds 2

Log 'nav: language menu (tap 1325,160), pick English (tap 1286,736)'
& $adb shell input tap 1325 160
Start-Sleep -Seconds 2
$null = Shot '05_lang_menu'
& $adb shell input tap 1286 736
Start-Sleep -Seconds 2
$null = Shot '06_home_en'

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

Log 'vision checks...'
Vision-Check '01_home_ru' 'главный экран на русском: заголовок «Колыбель цивилизаций», золотая кнопка «Смотреть галерею», тёмно-бирюзовый фон с орнаментом'
Vision-Check '02_gallery' 'галерея с карточками достопримечательностей: фото, названия, поисковая строка и фильтры эпох'
Vision-Check '04_detail_side' 'экран объекта Сиде: заголовок Сиде, блоки «Легенды и мифы» и «Как добраться», координаты'
Vision-Check '06_home_en' 'главный экран на английском: Cradle of civilisations, кнопка Open the gallery'
Vision-Check '05_lang_menu' 'открытое меню выбора языка с пунктами Русский, Türkçe, English'

Log "=== device_smoke done, exit=$exitCode ==="
exit $exitCode
