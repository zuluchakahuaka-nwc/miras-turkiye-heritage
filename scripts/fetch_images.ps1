param(
    [string]$Only = ''
)

$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $PSScriptRoot
$logDir = Join-Path $root 'logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir 'fetch_images.log'
function Log($msg) {
    $line = '{0} {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $msg
    Add-Content -Path $log -Value $line
    Write-Host $line
}

Add-Type -AssemblyName System.Drawing

$ua = 'MIRAS-heritage-app/1.0 (offline bundle builder; github.com/zuluchakahuaka-nwc/miras-turkiye-heritage)'

$sites = @(
    @{ id = 'gobekli-tepe';    ru = 'Гёбекли-Тепе';            en = 'Göbekli Tepe' }
    @{ id = 'catalhoyuk';      ru = 'Чатал-Хююк';              en = 'Çatalhöyük' }
    @{ id = 'hattusa';         ru = 'Хаттуса';                 en = 'Hattusa' }
    @{ id = 'troy';            ru = 'Троя';                    en = 'Troy' }
    @{ id = 'ephesus';         ru = 'Эфес';                    en = 'Ephesus' }
    @{ id = 'side';            ru = 'Сиде';                    en = 'Side, Turkey' }
    @{ id = 'aspendos';        ru = 'Аспендос';                en = 'Aspendos' }
    @{ id = 'pergamon';        ru = 'Пергам';                  en = 'Pergamon' }
    @{ id = 'nemrut';          ru = 'Немрут-Даг';              en = 'Mount Nemrut' }
    @{ id = 'pamukkale';       ru = 'Памуккале';               en = 'Pamukkale' }
    @{ id = 'myra';            ru = 'Мира (Ликия)';            en = 'Myra' }
    @{ id = 'halicarnassus';   ru = 'Галикарнасский мавзолей'; en = 'Mausoleum at Halicarnassus' }
    @{ id = 'cappadocia';      ru = 'Каппадокия';              en = 'Cappadocia' }
    @{ id = 'hagia-sophia';    ru = 'Айя-София';               en = 'Hagia Sophia' }
    @{ id = 'basilica-cistern';ru = 'Цистерна Базилика';       en = 'Basilica Cistern' }
    @{ id = 'topkapi';         ru = 'Дворец Топкапы';          en = 'Topkapı Palace' }
    @{ id = 'selimiye';        ru = 'Мечеть Селимие';          en = 'Selimiye Mosque, Edirne' }
    @{ id = 'dolmabahce';      ru = 'Дворец Долмабахче';       en = 'Dolmabahçe Palace' }
    @{ id = 'anitkabir';       ru = 'Аныткабир';               en = 'Anıtkabir' }
)

if ($Only -ne '') {
    $wanted = $Only.Split(',') | ForEach-Object { $_.Trim() }
    $sites = @($sites | Where-Object { $wanted -contains $_.id })
}
$sites = @($sites)

$imgDir = Join-Path $root 'miras\assets\images'
New-Item -ItemType Directory -Force -Path $imgDir | Out-Null
$tmpDir = Join-Path $logDir 'tmp_images'
New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null

function Get-PageImage($domain, $title) {
    $url = "https://$domain/w/api.php?action=query&format=json&redirects=1&prop=pageimages&piprop=thumbnail%7Cname&pithumbsize=1280&titles=$([uri]::EscapeDataString($title))"
    try {
        $r = Invoke-RestMethod -Uri $url -Headers @{ 'User-Agent' = $ua } -TimeoutSec 40
        $page = @($r.query.pages.PSObject.Properties.Value)[0]
        if ($null -ne $page -and $null -ne $page.thumbnail -and $page.thumbnail.source) {
            $clean = [string]$page.thumbnail.source
            $clean = $clean -replace '\?.*$', ''
            if ($clean -match '^https://') {
                return @{ thumb = $clean; file = [string]$page.pageimage }
            }
        }
    }
    catch {
        Log "    pageimages failed ($domain/${title}): $($_.Exception.Message)"
    }
    return $null
}

function Get-CommonsMeta($fileName) {
    $meta = @{ author = $null; license = $null; licenseUrl = $null }
    if ([string]::IsNullOrWhiteSpace($fileName)) { return $meta }
    try {
        $api = "https://commons.wikimedia.org/w/api.php?action=query&titles=$([uri]::EscapeDataString("File:$fileName"))&prop=imageinfo&iiprop=extmetadata&format=json"
        $r = Invoke-RestMethod -Uri $api -Headers @{ 'User-Agent' = $ua } -TimeoutSec 40
        $page = @($r.query.pages.PSObject.Properties.Value)[0]
        if ($null -ne $page -and $page.imageinfo) {
            $em = $page.imageinfo[0].extmetadata
            if ($em.Artist) {
                $author = $em.Artist.value -replace '<[^>]+>', ''
                $author = $author -replace '&amp;', '&' -replace '&quot;', '"' -replace '&#039;', "'"
                $meta.author = $author.Trim()
            }
            if ($em.LicenseShortName -and $em.LicenseShortName.value) { $meta.license = $em.LicenseShortName.value }
            if ($em.LicenseUrl -and $em.LicenseUrl.value) { $meta.licenseUrl = $em.LicenseUrl.value }
        }
    }
    catch {
        Log "    commons meta failed (${fileName}): $($_.Exception.Message)"
    }
    return $meta
}

function Convert-ToJpeg($src, $dst) {
    $img = [System.Drawing.Image]::FromFile($src)
    try {
        $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
        $params = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]88)
        $img.Save($dst, $codec, $params)
    }
    finally {
        $img.Dispose()
    }
}

$manifest = @()
$okCount = 0
Log "=== fetch_images start (sites=$($sites.Count)) ==="

foreach ($s in $sites) {
    Log "[$($s.id)] fetching"
    $img = $null
    $domain = 'ru.wikipedia.org'
    $resolvedTitle = $s.ru
    foreach ($attempt in 1..3) {
        $img = Get-PageImage 'ru.wikipedia.org' $s.ru
        if ($null -ne $img) { break }
        Start-Sleep -Seconds 15
    }
    if ($null -eq $img) {
        Log "    ru failed after retries, trying en"
        foreach ($attempt in 1..3) {
            $img = Get-PageImage 'en.wikipedia.org' $s.en
            if ($null -ne $img) { break }
            Start-Sleep -Seconds 15
        }
        $domain = 'en.wikipedia.org'
        $resolvedTitle = $s.en
    }
    if ($null -eq $img) {
        Log "    FAILED: no image source"
        $manifest += @{ site = $s.id; file = $null }
        continue
    }

    $tmpFile = Join-Path $tmpDir "$($s.id)_raw"
    $downloaded = $false
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            Invoke-WebRequest -Uri $img.thumb -OutFile $tmpFile -Headers @{ 'User-Agent' = $ua } -TimeoutSec 120 -UseBasicParsing
            $downloaded = $true
            break
        }
        catch {
            Log "    download attempt $attempt failed: $($_.Exception.Message)"
            Start-Sleep -Seconds 2
        }
    }
    if (-not $downloaded) {
        Log "    FAILED: download ($($img.thumb))"
        $manifest += @{ site = $s.id; file = $null }
        continue
    }

    $bytes = [System.IO.File]::ReadAllBytes($tmpFile)
    $isJpeg = $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xD8
    $isPng = $bytes[0] -eq 0x89 -and $bytes[1] -eq 0x50
    $outFile = Join-Path $imgDir "$($s.id).jpg"
    try {
        if ($isJpeg -and $bytes.Length -gt 30000) {
            Copy-Item $tmpFile $outFile -Force
        }
        elseif ($isPng -and $bytes.Length -gt 30000) {
            Convert-ToJpeg $tmpFile $outFile
        }
        else {
            throw "not an image or too small (size=$($bytes.Length))"
        }
        $check = [System.Drawing.Image]::FromFile($outFile)
        $w = $check.Width; $h = $check.Height
        $check.Dispose()
        if ($w -lt 400) { throw "too narrow: ${w}px" }
    }
    catch {
        Log "    FAILED: $($_.Exception.Message)"
        Remove-Item $outFile -ErrorAction SilentlyContinue
        $manifest += @{ site = $s.id; file = $null }
        continue
    }

    $meta = Get-CommonsMeta $img.file
    if (-not $meta.license) { $meta.license = 'See Commons file page' }

    $manifest += @{
        site       = $s.id
        file       = "$($s.id).jpg"
        source     = "https://commons.wikimedia.org/wiki/File:$([uri]::EscapeDataString($img.file))"
        author     = $meta.author
        license    = $meta.license
        licenseUrl = $meta.licenseUrl
        article    = "https://$domain/wiki/$([uri]::EscapeDataString($resolvedTitle))"
    }
    $finalSize = [math]::Round((Get-Item $outFile).Length / 1KB)
    Log "    OK: $($s.id).jpg (${finalSize} KB, $($img.file)), license=$($meta.license)"
    $okCount++
    Start-Sleep -Seconds 3
}

$manifestPath = Join-Path $imgDir 'manifest.json'
$merged = @{}
if (Test-Path $manifestPath) {
    try {
        $existing = Get-Content $manifestPath -Raw | ConvertFrom-Json
        foreach ($e in @($existing.images)) {
            if ($e.file) {
                $merged[$e.site] = @{
                    site = $e.site; file = $e.file; source = $e.source
                    author = $e.author; license = $e.license
                    licenseUrl = $e.licenseUrl; article = $e.article
                }
            }
        }
    }
    catch {
        Log "    existing manifest unreadable, rebuilding from scratch"
    }
}
foreach ($entry in $manifest) {
    if ($entry.file) {
        $merged[$entry.site] = $entry
    }
    elseif (-not $merged.ContainsKey($entry.site)) {
        $merged[$entry.site] = $entry
    }
}
$manifestJson = @{
    note      = 'Photos bundled from Wikimedia Commons for offline use. Attribution in-app (Sources screen).'
    generated = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    images    = @($merged.Values)
} | ConvertTo-Json -Depth 4
Set-Content -Path $manifestPath -Value $manifestJson -Encoding utf8

Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
Log "=== fetch_images done: ok=$okCount/$($sites.Count) ==="
if ($okCount -lt $sites.Count) { exit 2 }
exit 0
