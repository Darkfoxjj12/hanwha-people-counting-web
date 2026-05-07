# --- CONFIGURATION ---
$cameraIp = "192.168.20.102"
$userCam  = "admin"
$passCam  = "VOTRE_MOT_DE_PASSE"
$htmlPath = "C:\inetpub\Comptage\index.html"
$refresh  = 1 

$urlCam  = "http://$($cameraIp)/stw-cgi/eventsources.cgi?msubmenu=peoplecount&action=check"
$credCam = New-Object System.Management.Automation.PSCredential ($userCam, (ConvertTo-SecureString $passCam -AsPlainText -Force))

# Vérification du dossier de destination
if (!(Test-Path (Split-Path $htmlPath))) { New-Item -ItemType Directory -Path (Split-Path $htmlPath) -Force | Out-Null }

Write-Host "Service Hanwha -> Nx Witness actif ($refresh s)..." -ForegroundColor Cyan

while ($true) {
    try {
        # 1. RÉCUPÉRATION DES DONNÉES
        $response = Invoke-WebRequest -Uri $urlCam -Method Get -Credential $credCam -UseBasicParsing
        $data = @{}

        # 2. PARSING (Ligne de comptage Index 1)
        foreach ($l in ($response.Content -split "`r?`n")) {
            if ($l -match "Channel\.0\.LineIndex\.1\.(Name|InCount|OutCount)=(.*)") {
                $data[$matches[1]] = $matches[2].Trim()
            }
        }

        # 3. CALCULS
        $in = [int]$data["InCount"]
        $out = [int]$data["OutCount"]
        $inside = [math]::Max(0, ($in - $out))

        # 4. GÉNÉRATION DU DASHBOARD
        $html = @"
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="$refresh">
    <style>
        body { background-color: #1a1a1a; color: white; font-family: 'Segoe UI', sans-serif; text-align: center; padding: 20px; overflow: hidden; }
        .main-card { background: #2d2d2d; border-radius: 15px; padding: 30px; display: inline-block; border-top: 5px solid #00aeef; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        .title { font-size: 1.8em; color: #00aeef; margin-bottom: 20px; font-weight: bold; text-transform: uppercase; }
        .occupancy { font-size: 6em; font-weight: bold; color: #ffffff; margin: 10px 0; }
        .occupancy-label { font-size: 1.2em; color: #aaa; text-transform: uppercase; margin-bottom: 30px; }
        .stats { display: flex; justify-content: space-around; border-top: 1px solid #444; padding-top: 20px; gap: 40px; }
        .val { font-size: 2.5em; font-weight: bold; }
        .label { font-size: 0.8em; color: #888; text-transform: uppercase; }
        .in { color: #2ecc71; } .out { color: #e74c3c; }
        .update { font-size: 0.8em; color: #444; margin-top: 30px; }
    </style>
</head>
<body>
    <div class="main-card">
        <div class="title">$($data["Name"])</div>
        <div class="occupancy">$inside</div>
        <div class="occupancy-label">Personnes à l'intérieur</div>
        <div class="stats">
            <div><div class="val in">$in</div><div class="label">Entrées</div></div>
            <div><div class="val out">$out</div><div class="label">Sorties</div></div>
        </div>
    </div>
    <div class="update">Dernière MAJ : $(Get-Date -Format 'HH:mm:ss')</div>
</body>
</html>
"@
        $html | Set-Content -Path $htmlPath -Encoding UTF8
        Write-Host "." -NoNewline -ForegroundColor Green

    } catch {
        Write-Host " [ERR: $($_.Exception.Message)]" -ForegroundColor Red
    }
    Start-Sleep -Seconds $refresh
}