# Script de démarrage pour TUVCB
# Usage: .\start-dev.ps1

Write-Host "🚀 Démarrage de l'environnement TUVCB..." -ForegroundColor Green

# Vérifier que Docker est démarré
try {
    docker --version | Out-Null
    Write-Host "✅ Docker détecté" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker n'est pas démarré ou installé" -ForegroundColor Red
    exit 1
}

# Arrêter les services existants
Write-Host "🛑 Arrêt des services existants..." -ForegroundColor Yellow
docker-compose down

# Construire et démarrer tous les services
Write-Host "🏗️ Construction et démarrage des services..." -ForegroundColor Yellow
docker-compose up -d --build

# Attendre que les services soient prêts
Write-Host "⏳ Attente du démarrage des services..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Vérifier l'état des services
Write-Host "📊 État des services:" -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "🎉 Services disponibles:" -ForegroundColor Green
Write-Host "   Frontend:        http://app.localhost" -ForegroundColor White
Write-Host "   Traefik:         http://localhost:8080" -ForegroundColor White
Write-Host "   Consul:          http://localhost:8500" -ForegroundColor White
Write-Host "   Users API Docs:  http://app.localhost/api/users/docs" -ForegroundColor White
Write-Host ""
Write-Host "📝 Commandes utiles:" -ForegroundColor Cyan
Write-Host "   Voir les logs:           docker-compose logs -f" -ForegroundColor White
Write-Host "   Arrêter les services:    docker-compose down" -ForegroundColor White
Write-Host "   Rebuild un service:      docker-compose up -d --build <service>" -ForegroundColor White
