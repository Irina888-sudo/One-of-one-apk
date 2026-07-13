$mysqlPath = "C:\xampp\mysql\bin\mysql.exe"
$sqlFiles = @(
    "C:\Users\Rajo\Documents\GitHub\One-of-one-apk\sql\oneofone.sql",
    "C:\Users\Rajo\Documents\GitHub\One-of-one-apk\sql\mock_dashboard_data.sql"
)

foreach ($sqlFile in $sqlFiles) {
    Write-Host "Execution de: $sqlFile"
    Get-Content $sqlFile | & $mysqlPath -u root
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Fichier execute avec succes"
    } else {
        Write-Host "✗ Erreur lors de l'execution du fichier"
    }
}

Write-Host "Deploiement SQL termine!"
