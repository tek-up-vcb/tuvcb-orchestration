# 📊 Guide Monitoring : Prometheus & Grafana

## 🎯 Qu'est-ce que le monitoring et pourquoi en avez-vous besoin ?

Imaginez que vous conduisez une voiture **sans tableau de bord** : pas de compteur de vitesse, pas de jauge d'essence, pas de voyants. C'est exactement ce que c'est que de faire tourner des applications web sans monitoring !

Le monitoring vous permet de :
- 🚨 **Détecter les problèmes avant vos utilisateurs**
- 📈 **Optimiser les performances de vos services**
- 🔍 **Comprendre comment vos utilisateurs utilisent votre application**
- 💰 **Réduire les coûts en optimisant les ressources**

---

## 🔍 Prometheus : Le "Collecteur de Données"

### Qu'est-ce que Prometheus ?
Prometheus est comme un **comptable méticuleux** qui note tout ce qui se passe dans votre infrastructure :
- Combien de requêtes reçoit chaque service
- Combien de temps prend chaque réponse
- Combien de mémoire utilise chaque conteneur
- Combien d'erreurs se produisent

### Comment ça marche dans votre projet ?

#### 1. **Collecte automatique** 
Prometheus va "interroger" vos services toutes les 15 secondes :
```
Prometheus → "Hé Traefik, combien de requêtes as-tu reçues ?"
Traefik → "J'ai reçu 1,230 requêtes, dont 45 erreurs 404"
```

#### 2. **Sources de données configurées** :
- **Traefik** : Métriques de proxy (requêtes, erreurs, temps de réponse)
- **cAdvisor** : Utilisation CPU/RAM de vos conteneurs
- **Node Exporter** : État de votre serveur (disque, réseau)
- **Vos services NestJS** : Métriques métier personnalisées

#### 3. **Stockage temporel**
Prometheus garde un historique de toutes ces données, comme un carnet de bord.

### 📊 Exemples concrets de métriques collectées :

```bash
# Nombre de requêtes HTTP par service
http_requests_total{service="tuvcb-service-users", status="200"} 1523

# Temps de réponse moyen
http_request_duration_seconds{service="tuvcb-service-auth"} 0.045

# Utilisation mémoire d'un conteneur
container_memory_usage_bytes{name="tuvcb-service-users"} 128MB

# Erreurs par minute
http_requests_total{status="500"} 3
```

---

## 📈 Grafana : Le "Créateur de Tableaux de Bord"

### Qu'est-ce que Grafana ?
Si Prometheus est le comptable, Grafana est le **designer graphique** qui transforme les chiffres en beaux graphiques compréhensibles.

### Pourquoi Grafana avec Prometheus ?
Prometheus seul, c'est comme avoir une base de données pleine de chiffres. Grafana transforme ça en :
- 📊 **Graphiques en temps réel**
- 🎨 **Dashboards visuels**
- 🚨 **Alertes automatiques**
- 📱 **Interface mobile-friendly**

### 🖼️ Types de visualisations possibles :

#### 1. **Graphiques de performance** :
```
Temps de réponse de vos APIs
    ↗️ 
   ↗️  ↘️
  ↗️    ↘️
 ↗️      ↘️
────────────→ Temps
```

#### 2. **Jauges de ressources** :
```
CPU Usage: [████████░░] 80%
RAM Usage: [██████░░░░] 60%
Disk Usage: [███░░░░░░░] 30%
```

#### 3. **Alertes visuelles** :
```
🟢 Service Users: OK (response time: 45ms)
🟡 Service Auth: WARNING (response time: 250ms)
🔴 Service Diploma: ERROR (5xx errors detected)
```

---

## 🚀 Guide d'utilisation pratique

### 1. **Accéder à vos dashboards** :

```bash
# Prometheus (données brutes)
http://localhost:9090

# Grafana (dashboards visuels)  
http://localhost:3001
# Login: admin / Password: admin
```

### 2. **Premiers pas avec Prometheus** :

1. Allez sur `http://localhost:9090`
2. Dans la barre de recherche, tapez : `up`
3. Cliquez sur "Execute" → Vous voyez quels services sont en ligne !

**Requêtes utiles à essayer** :
```bash
# Voir tous les services en ligne
up

# Requêtes HTTP par seconde
rate(traefik_service_requests_total[1m])

# Utilisation mémoire des conteneurs
container_memory_usage_bytes

# Temps de réponse moyen
avg(traefik_service_request_duration_seconds)
```

### 3. **Premiers pas avec Grafana** :

1. Allez sur `http://localhost:3001`
2. Login : `admin` / Password : `admin`
3. Dans le menu, cliquez sur "+" puis "Import"
4. Cherchez "Traefik Dashboard" ou utilisez l'ID : `4475`

---

## 🎯 Cas d'usage concrets pour votre projet TUVCB

### Scénario 1 : **Détection de surcharge**
```
Problème : "Mon app est lente ce matin"
Solution Grafana : 
- Graphique CPU → Pic à 95% sur service-users
- Graphique requêtes → 10x plus de trafic que d'habitude
- Action : Scaler le service ou optimiser le code
```

### Scénario 2 : **Debugging d'erreurs**
```
Problème : "Les utilisateurs n'arrivent pas à se connecter"
Solution Prometheus : 
- Requête : http_requests_total{service="auth", status="500"}
- Résultat : 50 erreurs dans la dernière heure
- Action : Vérifier les logs du service auth
```

### Scénario 3 : **Optimisation business**
```
Insight : "Quel service est le plus utilisé ?"
Dashboard Grafana :
- service-users : 10,000 req/h
- service-auth : 8,000 req/h  
- service-diploma : 500 req/h
- Action : Prioriser l'optimisation de service-users
```

---

## 📋 Checklist de monitoring pour votre équipe

### 🟢 **Monitoring de base** (Implémenté) :
- [x] Santé des services (UP/DOWN)
- [x] Temps de réponse des APIs
- [x] Nombre de requêtes par service
- [x] Utilisation CPU/RAM des conteneurs
- [x] Détection des erreurs HTTP

### 🟡 **Monitoring avancé** (À faire) :
- [ ] Métriques métier (nombre d'utilisateurs connectés)
- [ ] Alertes automatiques (email/Slack)
- [ ] Monitoring de la base de données
- [ ] Suivi des déploiements
- [ ] Monitoring de sécurité

### 🔴 **Monitoring expert** (Optionnel) :
- [ ] Tracing distribué (voir les requêtes entre services)
- [ ] Logs centralisés (ELK Stack)
- [ ] Monitoring mobile/frontend
- [ ] Prédictions de charge

---

## 🛠️ Configuration pour votre équipe

### Variables importantes à surveiller :

#### **Performance** :
- Temps de réponse < 200ms (bon), < 500ms (acceptable), > 1s (problème)
- Taux d'erreur < 1% (bon), < 5% (acceptable), > 10% (critique)

#### **Ressources** :
- CPU < 70% (bon), < 85% (surveillance), > 90% (action requise)
- RAM < 80% (bon), < 90% (surveillance), > 95% (critique)

#### **Business** :
- Nombre d'utilisateurs actifs
- Requêtes d'authentification réussies/échouées
- Temps de génération des diplômes

---

## 🆘 Dépannage courant

### Prometheus ne collecte pas de données :
```bash
# Vérifier la config
docker-compose logs prometheus

# Vérifier les targets
# Aller sur http://localhost:9090/targets
```

### Grafana ne se connecte pas à Prometheus :
```bash
# Dans Grafana : Configuration > Data Sources
# URL doit être : http://prometheus:9090
```

### Dashboard vide :
```bash
# Vérifier que les services exposent /metrics
curl http://localhost:8080/metrics
```

---

## 🎓 Pour aller plus loin

### Ressources utiles :
- [Documentation Prometheus](https://prometheus.io/docs/)
- [Dashboards Grafana communautaires](https://grafana.com/grafana/dashboards/)
- [Alerting avec Prometheus](https://prometheus.io/docs/alerting/latest/overview/)

### Prochaines étapes suggérées :
1. Créer des dashboards personnalisés pour votre métier
2. Configurer des alertes email/Slack
3. Ajouter des métriques dans vos services NestJS
4. Monitorer la base de données PostgreSQL

---

*Cette documentation vous donne les bases pour comprendre et utiliser efficacement Prometheus et Grafana dans votre architecture microservices TUVCB !* 🚀
