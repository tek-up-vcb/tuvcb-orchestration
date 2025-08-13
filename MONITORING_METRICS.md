# 📊 Métriques et Alertes - Aide-mémoire

## 🎯 Métriques clés à surveiller

### ⚡ Performance des APIs

| Métrique | Requête Prometheus | Seuil Normal | Seuil Critique |
|----------|-------------------|--------------|----------------|
| **Temps de réponse** | `histogram_quantile(0.95, rate(traefik_service_request_duration_seconds_bucket[5m]))` | < 500ms | > 2s |
| **Requêtes/seconde** | `rate(traefik_service_requests_total[1m])` | - | > 1000/s |
| **Taux d'erreur** | `rate(traefik_service_requests_total{code=~"5.."}[1m]) / rate(traefik_service_requests_total[1m]) * 100` | < 1% | > 5% |

### 🖥️ Ressources système

| Métrique | Requête Prometheus | Seuil Normal | Seuil Critique |
|----------|-------------------|--------------|----------------|
| **CPU conteneur** | `rate(container_cpu_usage_seconds_total[1m]) * 100` | < 70% | > 90% |
| **RAM conteneur** | `container_memory_usage_bytes / container_spec_memory_limit_bytes * 100` | < 80% | > 95% |
| **Espace disque** | `(1 - node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100` | < 80% | > 90% |

### 🔍 Services spécifiques TUVCB

| Service | Métrique importante | Requête |
|---------|-------------------|---------|
| **tuvcb-service-auth** | Tentatives de connexion | `rate(http_requests_total{service="auth", endpoint="/login"}[1m])` |
| **tuvcb-service-users** | Créations d'utilisateurs | `rate(http_requests_total{service="users", method="POST"}[1m])` |
| **tuvcb-service-diploma** | Génération de diplômes | `rate(http_requests_total{service="diploma", method="POST"}[1m])` |

---

## 🚨 Alertes recommandées

### Alertes critiques (notification immédiate)

```yaml
# Service DOWN
alert: ServiceDown
expr: up{job!="node-exporter"} == 0
for: 1m
labels:
  severity: critical
annotations:
  summary: "Service {{ $labels.instance }} is down"

# Taux d'erreur élevé
alert: HighErrorRate
expr: rate(traefik_service_requests_total{code=~"5.."}[5m]) / rate(traefik_service_requests_total[5m]) > 0.05
for: 5m
labels:
  severity: critical
annotations:
  summary: "High error rate on {{ $labels.service }}"

# Temps de réponse élevé
alert: HighResponseTime
expr: histogram_quantile(0.95, rate(traefik_service_request_duration_seconds_bucket[5m])) > 2
for: 5m
labels:
  severity: critical
annotations:
  summary: "High response time on {{ $labels.service }}"
```

### Alertes warning (notification différée)

```yaml
# CPU élevé
alert: HighCPU
expr: rate(container_cpu_usage_seconds_total[1m]) * 100 > 80
for: 10m
labels:
  severity: warning
annotations:
  summary: "High CPU usage on {{ $labels.name }}"

# RAM élevée
alert: HighMemory
expr: container_memory_usage_bytes / container_spec_memory_limit_bytes * 100 > 85
for: 10m
labels:
  severity: warning
annotations:
  summary: "High memory usage on {{ $labels.name }}"
```

---

## 📈 Dashboards recommandés par rôle

### 👨‍💻 **Développeur**
- Temps de réponse par endpoint
- Taux d'erreur par service
- Nombre de requêtes par heure
- Performance de la base de données

### 🔧 **DevOps/SRE**
- Santé globale des services
- Utilisation des ressources
- Métriques réseau
- Alertes actives

### 📊 **Business/Product**
- Nombre d'utilisateurs actifs
- Fonctionnalités les plus utilisées
- Temps de génération des diplômes
- Pic de charge par heure

---

## 🛠️ Configuration des alertes

### 1. Créer le fichier d'alertes
```yaml
# monitoring/alerts.yml
groups:
  - name: tuvcb.rules
    rules:
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service is down"
          description: "{{ $labels.instance }} has been down for more than 1 minute"
```

### 2. Ajouter à la config Prometheus
```yaml
# monitoring/prometheus.yml
rule_files:
  - "alerts.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

### 3. Configurer Alertmanager (optionnel)
```yaml
# monitoring/alertmanager.yml
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@tuvcb.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
  - name: 'web.hook'
    email_configs:
      - to: 'admin@tuvcb.com'
        subject: 'TUVCB Alert: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
```

---

## 🔧 Requêtes de dépannage courantes

### Diagnostic de performance
```bash
# Top 5 des endpoints les plus lents
topk(5, histogram_quantile(0.95, rate(traefik_service_request_duration_seconds_bucket[5m])))

# Services avec le plus d'erreurs
topk(5, rate(traefik_service_requests_total{code=~"5.."}[5m]))

# Conteneurs utilisant le plus de CPU
topk(5, rate(container_cpu_usage_seconds_total[1m]))

# Conteneurs utilisant le plus de RAM
topk(5, container_memory_usage_bytes)
```

### Analyse de charge
```bash
# Évolution du trafic sur 24h
rate(traefik_service_requests_total[1m])[24h:1m]

# Pic de charge par service
max_over_time(rate(traefik_service_requests_total[1m])[1h])

# Répartition du trafic par service
sum by (service) (rate(traefik_service_requests_total[1m]))
```

---

## 📱 Monitoring mobile

### Grafana Mobile App
1. Télécharger l'app Grafana sur votre téléphone
2. Ajouter votre serveur : `http://your-server:3001`
3. Créer des dashboards optimisés mobile

### Notifications push
- Configurer Alertmanager avec Pushover ou Telegram
- Recevoir les alertes critiques sur mobile
- Dashboard mobile pour vérification rapide

---

*Cette documentation vous donne tous les outils pour un monitoring professionnel de votre infrastructure TUVCB !* 🚀
