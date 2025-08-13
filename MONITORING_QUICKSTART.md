# 🚀 Quick Start : Monitoring en 5 minutes

## TL;DR : À quoi ça sert ?

**Prometheus** = Collecte les données de performance ⚡  
**Grafana** = Affiche de beaux graphiques 📊  
**Ensemble** = Vous savez si votre app fonctionne bien ! ✅

---

## 🎯 Accès rapide

| Service | URL | Utilisateur | Mot de passe | À quoi ça sert |
|---------|-----|-------------|--------------|----------------|
| **Grafana** | http://localhost:3001 | admin | admin | 📊 Voir les graphiques |
| **Prometheus** | http://localhost:9090 | - | - | 🔍 Voir les données brutes |
| **Traefik** | http://localhost:8080 | - | - | 🚦 État des services |
| **Node Exporter** | http://localhost:9100 | - | - | 💻 Stats du serveur |
| **cAdvisor** | http://localhost:8081 | - | - | 🐳 Stats des conteneurs |

---

## ⚡ Test rapide : "Est-ce que ça marche ?"

### 1. Vérifiez que tous vos services sont UP :
```bash
# Dans votre terminal
docker-compose ps
```
✅ Tous les services doivent être "Up"

### 2. Testez Prometheus :
1. Allez sur http://localhost:9090
2. Tapez `up` dans la barre de recherche
3. Cliquez "Execute"
4. ✅ Vous devez voir vos services avec la valeur "1"

### 3. Testez Grafana :
1. Allez sur http://localhost:3001
2. Login : admin / admin
3. ✅ Vous arrivez sur l'interface Grafana

---

## 📊 Créer votre premier dashboard en 2 minutes

### Dans Grafana :
1. Cliquez sur "+" dans le menu de gauche
2. Sélectionnez "Import"
3. Entrez cet ID : **4475** (Dashboard Traefik)
4. Cliquez "Load" puis "Import"
5. 🎉 Vous avez votre premier dashboard !

---

## 🔍 Requêtes utiles pour débuter

### Dans Prometheus (http://localhost:9090) :

```bash
# Voir quels services sont en ligne
up

# Nombre de requêtes par seconde sur Traefik
rate(traefik_service_requests_total[1m])

# Utilisation mémoire de vos conteneurs  
container_memory_usage_bytes

# Temps de réponse moyen de vos APIs
traefik_service_request_duration_seconds
```

---

## 🚨 Indicateurs clés à surveiller

### 🟢 **Tout va bien si :**
- Tous les services sont "UP" dans Prometheus
- Temps de réponse < 500ms
- Pas d'erreurs 500 dans les dernières 5 minutes
- CPU < 80% et RAM < 80%

### 🔴 **Problème si :**
- Un service est "DOWN"
- Temps de réponse > 2 secondes
- Beaucoup d'erreurs 500
- CPU > 95% ou RAM > 95%

---

## 🛠️ Commandes de dépannage

```bash
# Redémarrer le monitoring
docker-compose restart prometheus grafana

# Voir les logs si problème
docker-compose logs prometheus
docker-compose logs grafana

# Vérifier les métriques Traefik
curl http://localhost:8080/metrics
```

---

## 📱 Interface mobile

Grafana fonctionne parfaitement sur mobile ! Ajoutez l'URL à votre écran d'accueil pour surveiller vos services en déplacement.

---

**💡 Conseil :** Laissez un onglet Grafana ouvert pendant que vous développez. Vous verrez en temps réel l'impact de vos modifications ! 🚀
