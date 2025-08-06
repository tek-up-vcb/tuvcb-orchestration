#!/bin/bash

echo "🚀 Démarrage de la plateforme TUVCB..."

# Arrêter les services existants
echo "📦 Arrêt des services existants..."
docker-compose down

# Construire et démarrer les services
echo "🔨 Construction et démarrage des services..."
docker-compose up --build -d

# Attendre que les services soient prêts
echo "⏳ Attente du démarrage des services..."
sleep 10

# Vérifier l'état des services
echo "🔍 Vérification de l'état des services..."
docker-compose ps

echo ""
echo "✅ Plateforme démarrée avec succès !"
echo ""
echo "🌐 Accès aux services :"
echo "   - Frontend:          http://app.localhost"
echo "   - API Auth:          http://auth.localhost"
echo "   - API Test:          http://api.localhost"
echo "   - Consul UI:         http://localhost:8500"
echo "   - Traefik Dashboard: http://localhost:8080"
echo ""
echo "🔒 Test de l'authentification :"
echo "1. Aller sur http://app.localhost"
echo "2. Cliquer sur 'Login'"
echo "3. Connecter MetaMask"
echo "4. Signer le message d'authentification"
echo ""
echo "📋 Logs des services :"
echo "   docker-compose logs -f [service-name]"
