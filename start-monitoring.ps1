# Script de démarrage avec monitoring enrichi
Write-Host "🚀 Démarrage de la stack TUVCB avec monitoring avancé..." -ForegroundColor Green

# Créer les répertoires de logs si ils n'existent pas
if (!(Test-Path ".\traefik\logs")) {
    New-Item -ItemType Directory -Path ".\traefik\logs" -Force
    Write-Host "📁 Répertoire de logs Traefik créé" -ForegroundColor Yellow
}

# Démarrer tous les services
Write-Host "📦 Démarrage des services..." -ForegroundColor Blue
docker-compose up -d

# Attendre que les services soient prêts
Write-Host "⏳ Attente du démarrage des services..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Vérifier l'état des services
Write-Host "🔍 Vérification de l'état des services..." -ForegroundColor Blue
docker-compose ps

Write-Host ""
Write-Host "🎉 Stack démarrée avec succès !" -ForegroundColor Green
Write-Host ""
Write-Host "🏠 HUB DE MONITORING CENTRAL :" -ForegroundColor Cyan
Write-Host "  • Hub TUVCB            : http://monitoring.localhost" -ForegroundColor Yellow
Write-Host "  • Hub (direct)         : http://localhost:3004" -ForegroundColor White
Write-Host ""
Write-Host "📊 Dashboards disponibles :" -ForegroundColor Cyan
Write-Host "  • Traefik Dashboard    : http://localhost:8080" -ForegroundColor White
Write-Host "  • Traefik (via domain) : http://traefik.localhost" -ForegroundColor White
Write-Host "  • Consul UI            : http://localhost:8500" -ForegroundColor White
Write-Host "  • Prometheus           : http://localhost:9090" -ForegroundColor White
Write-Host "  • Grafana              : http://localhost:3001 (admin/admin)" -ForegroundColor White
Write-Host "  • Node Exporter        : http://localhost:9100" -ForegroundColor White
Write-Host "  • cAdvisor             : http://localhost:8081" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Applications :" -ForegroundColor Cyan
Write-Host "  • Frontend             : http://app.localhost" -ForegroundColor White
Write-Host "  • Monitoring Stack     : http://monitoring.localhost" -ForegroundColor White
Write-Host ""
Write-Host "📈 Métriques Traefik disponibles sur :" -ForegroundColor Cyan
Write-Host "  • http://localhost:8080/metrics" -ForegroundColor White
Write-Host "  • http://monitoring.localhost/metrics" -ForegroundColor White
Write-Host ""
Write-Host "💡 Conseil : Ajoutez ces entrées à votre fichier hosts :" -ForegroundColor Yellow
Write-Host "127.0.0.1 app.localhost" -ForegroundColor Gray
Write-Host "127.0.0.1 traefik.localhost" -ForegroundColor Gray
Write-Host "127.0.0.1 monitoring.localhost" -ForegroundColor Gray
