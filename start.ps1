Write-Host "🚀 Démarrage de la plateforme TUVCB..." -ForegroundColor Green

# Arrêter les services existants
Write-Host "📦 Arrêt des services existants..." -ForegroundColor Yellow
docker-compose down

# Construire et démarrer les services
Write-Host "🔨 Construction et démarrage des services..." -ForegroundColor Yellow
docker-compose up --build -d

# Attendre que les services soient prêts
Write-Host "⏳ Attente du démarrage des services..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Vérifier l'état des services
Write-Host "🔍 Vérification de l'état des services..." -ForegroundColor Yellow
docker-compose ps

Write-Host ""
Write-Host "✅ Plateforme démarrée avec succès !" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Accès aux services :" -ForegroundColor Cyan
Write-Host "   - Frontend:          http://app.localhost" -ForegroundColor White
Write-Host "   - API Auth:          http://auth.localhost" -ForegroundColor White
Write-Host "   - API Test:          http://api.localhost" -ForegroundColor White
Write-Host "   - Consul UI:         http://localhost:8500" -ForegroundColor White
Write-Host "   - Traefik Dashboard: http://localhost:8080" -ForegroundColor White
Write-Host ""
Write-Host "🔒 Test de l'authentification :" -ForegroundColor Cyan
Write-Host "1. Aller sur http://app.localhost" -ForegroundColor White
Write-Host "2. Cliquer sur 'Login'" -ForegroundColor White
Write-Host "3. Connecter MetaMask" -ForegroundColor White
Write-Host "4. Signer le message d'authentification" -ForegroundColor White
Write-Host ""
Write-Host "📋 Logs des services :" -ForegroundColor Cyan
Write-Host "   docker-compose logs -f [service-name]" -ForegroundColor White
