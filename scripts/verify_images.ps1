param(
    [string]$Only = '',
    [int]$Max = 5,
    [int]$CallTimeoutSec = 120,
    [switch]$Redo
)

$root = Split-Path -Parent $PSScriptRoot
$logDir = Join-Path $root 'logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir 'verify_images.log'
$statePath = Join-Path $logDir 'verify_state.json'
function Log($msg) {
    $line = '{0} {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $msg
    Add-Content -Path $log -Value $line
    Write-Host $line
}

$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
if (-not (Get-Command mcp-cli -ErrorAction SilentlyContinue)) {
    Log 'FATAL: mcp-cli not found in PATH'
    exit 1
}

Add-Type -AssemblyName System.Drawing

$orderedIds = @(
    'gobekli-tepe', 'catalhoyuk', 'hattusa', 'troy', 'ephesus', 'side',
    'aspendos', 'pergamon', 'nemrut', 'pamukkale', 'myra', 'halicarnassus',
    'cappadocia', 'hagia-sophia', 'basilica-cistern', 'topkapi', 'selimiye',
    'dolmabahce', 'anitkabir'
)

$expectations = @{
    'gobekli-tepe'     = 'мегалитические Т-образные колонны древнего храмового комплекса Гёбекли-Тепе под открытым небом'
    'catalhoyuk'       = 'раскопки неолитического поселения Чатал-Хююк'
    'hattusa'          = 'Львиные ворота Хаттусы или руины хеттской столицы'
    'troy'             = 'древний город Троя: руины, стены или старинное изображение города'
    'ephesus'          = 'фасад библиотеки Цельса в Эфесе'
    'side'             = 'колонны храма Аполлона в Сиде, желательно у моря'
    'aspendos'         = 'римский театр Аспендоса'
    'pergamon'         = 'руины античного Пергама на холме (акрополь), НЕ модель в музее'
    'nemrut'           = 'каменные головы колоссов на террасе горы Немрут'
    'pamukkale'        = 'белые травертиновые террасы Памуккале'
    'myra'             = 'скальные ликийские гробницы Миры или её римский театр'
    'halicarnassus'    = 'руины мавзолея в Галикарнасе'
    'cappadocia'       = 'скальные образования Каппадокии (пери бакылары) или пещерный город'
    'hagia-sophia'     = 'здание Айя-Софии с куполом и минаретами'
    'basilica-cistern' = 'колонны подземной цистерны Базилики в Стамбуле'
    'topkapi'          = 'дворец Топкапы: здание, двор или павильон'
    'selimiye'         = 'мечеть Селимие в Эдирне с минаретами и куполом'
    'dolmabahce'       = 'дворец Долмабахче на берегу Босфора'
    'anitkabir'        = 'мавзолей Аныткабир в Анкаре с колоннадой'
}

$state = @{}
if (Test-Path $statePath) {
    try {
        $loaded = Get-Content $statePath -Raw | ConvertFrom-Json
        foreach ($p in $loaded.PSObject.Properties) { $state[$p.Name] = [string]$p.Value }
    }
    catch { Log 'state unreadable, starting fresh' }
}
if ($Redo) { $state.Clear() }

$imgDir = Join-Path $root 'miras\assets\images'
$pngDir = Join-Path $logDir 'verify_png'
New-Item -ItemType Directory -Force -Path $pngDir | Out-Null

$ids = @($orderedIds)
if ($Only -ne '') {
    $wanted = $Only.Split(',') | ForEach-Object { $_.Trim() }
    $ids = @($ids | Where-Object { $wanted -contains $_ })
}
$todo = @($ids | Where-Object { -not $state.ContainsKey($_) })
Log "=== verify_images: requested=$($ids.Count) todo=$($todo.Count) done_already=$($ids.Count - $todo.Count) (Max=$Max, timeout=${CallTimeoutSec}s) ==="

function Save-State {
    ($state | ConvertTo-Json) | Set-Content -Path $statePath -Encoding utf8
}

function Convert-ToPng($src, $dst) {
    $img = [System.Drawing.Image]::FromFile($src)
    try {
        $w = $img.Width; $h = $img.Height
        $maxSide = 1400
        if ($w -gt $maxSide -or $h -gt $maxSide) {
            $scale = [math]::Min($maxSide / $w, $maxSide / $h)
            $nw = [int]($w * $scale); $nh = [int]($h * $scale)
            $bmp = New-Object System.Drawing.Bitmap($nw, $nh)
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.DrawImage($img, 0, 0, $nw, $nh)
            $g.Dispose()
            $bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
            $bmp.Dispose()
        }
        else {
            $img.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
        }
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
        if ($l -match '^\[(zai-vision\]|)' ) { continue }
        if ($l -match '^\d{4}-\d{2}-\d{2}T') { continue }
        if ($l -match '^(YES|ДА)\b') { return 'YES' }
        if ($l -match '^(NO|НЕТ)\b') { return 'NO' }
        if ($l -match '\b(YES|ДА)\b' -and $l -notmatch '\b(NO|НЕТ)\b') { return 'YES' }
        if ($l -match '\b(NO|НЕТ)\b') { return 'NO' }
        return 'UNPARSED::' + $l
    }
    return 'EMPTY'
}

$processed = 0
foreach ($id in $todo) {
    if ($processed -ge $Max) { Log "batch limit ($Max) reached, exiting incrementally"; break }
    $jpg = Join-Path $imgDir "$id.jpg"
    if (-not (Test-Path $jpg)) {
        Log "[$id] MISSING FILE"
        $state[$id] = 'MISSING'
        Save-State
        $processed++
        continue
    }
    $png = Join-Path $pngDir "$id.png"
    try {
        if (-not (Test-Path $png)) { Convert-ToPng $jpg $png }
    }
    catch {
        Log "[$id] PNG convert failed: $($_.Exception.Message)"
        $state[$id] = 'CONVERT_FAIL'
        Save-State
        $processed++
        continue
    }
    if (-not (Test-Path $png)) {
        Log "[$id] PNG still missing after convert"
        $state[$id] = 'CONVERT_FAIL'
        Save-State
        $processed++
        continue
    }
    if ((Get-Item $png).Length -gt 4.8MB) {
        Log "[$id] PNG too big ($([math]::Round((Get-Item $png).Length/1MB,1)) MB), skipping"
        $state[$id] = 'TOO_BIG'
        Save-State
        $processed++
        continue
    }

    $pngForJson = $png.Replace('\', '/')
    $prompt = "На фото должно быть: $($expectations[$id]). Начни ответ строго с одного слова YES (если это оно) или NO (если совсем другое), затем одним предложением опиши, что видно."
    $prompt = $prompt -replace '"', ''
    $json = '{"image_source":"' + $pngForJson + '","prompt":"' + $prompt + '"}'

    Log "[$id] asking vision..."
    $job = Start-Job -ScriptBlock {
        param($j)
        mcp-cli call zai-vision analyze_image $j 2>&1 | Out-String
    } -ArgumentList $json
    if (Wait-Job $job -Timeout $CallTimeoutSec) {
        $out = Receive-Job $job | Out-String
        Remove-Job $job -Force
        $verdict = Parse-Verdict $out
        $state[$id] = $verdict
        Save-State
        Log "[$id] $verdict"
    }
    else {
        Stop-Job $job -Force
        Remove-Job $job -Force
        Get-Process -Name mcp-cli -ErrorAction SilentlyContinue | Stop-Process -Force
        $state[$id] = 'TIMEOUT'
        Save-State
        Log "[$id] TIMEOUT (${CallTimeoutSec}s), mcp-cli killed"
    }
    $processed++
    Start-Sleep -Seconds 1
}

$no = @($state.Keys | Where-Object { $state[$_] -eq 'NO' })
$bad = @($state.Keys | Where-Object { $state[$_] -notin @('YES', 'NO') })
Log "=== verify batch done. state totals: YES=$(@($state.Keys | Where-Object { $state[$_] -eq 'YES' }).Count) NO=$($no.Count) other=$($bad.Count) ==="
if ($no.Count -gt 0) { Log "NO: $($no -join ', ')" }
if ($bad.Count -gt 0) { Log ('OTHER: ' + (($bad | ForEach-Object { '{0}={1}' -f $_, $state[$_] }) -join '; ')) }
if ($bad.Count -gt 0) { exit 2 }
exit 0
