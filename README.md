# TUVCB Platform

Une plateforme complète avec authentification MetaMask et microservices.

## Architecture

- **tuvcb-front**: Interface utilisateur React avec authentification MetaMask
- **tuvcb-service-auth**: Service d'authentification avec signature cryptographique et JWT
- **tuvcb-service-test**: Service de test (template)
- **Traefik**: Reverse proxy et load balancer
- **Consul**: Service discovery et configuration
- **MongoDB**: Base de données pour les utilisateurs

## Services

### Frontend (tuvcb-front)
- **URL**: http://app.localhost
- **Port**: 5173
- Interface utilisateur avec intégration MetaMask
- Authentification par signature cryptographique
- Gestion d'état global pour l'authentification

### Service d'authentification (tuvcb-service-auth)
- **URL**: http://auth.localhost  
- **Port**: 3001
- Authentification MetaMask avec nonce
- Vérification de signature cryptographique
- Tokens JWT stockés en cookies HTTP-only
- Gestion des utilisateurs avec MongoDB

### Service de test (tuvcb-service-test)
- **URL**: http://api.localhost
- **Port**: 3000
- Template de microservice NestJS

## Flux d'authentification

1. **Connexion du wallet**: L'utilisateur connecte son wallet MetaMask
2. **Génération du nonce**: Le service auth génère un nonce unique
3. **Signature**: L'utilisateur signe un message contenant le nonce
4. **Vérification**: Le service vérifie la signature et l'adresse
5. **Token JWT**: Un token JWT est émis et stocké en cookie HTTP-only
6. **Accès protégé**: L'utilisateur peut accéder aux ressources protégées

## Démarrage rapide

1. **Prérequis**:
   - Docker et Docker Compose
   - Extension MetaMask dans le navigateur

2. **Démarrer l'infrastructure**:
   ```bash
   docker-compose up -d
   ```

3. **Accéder aux services**:
   - Frontend: http://app.localhost
   - API Auth: http://auth.localhost
   - API Test: http://api.localhost
   - Consul UI: http://localhost:8500
   - Traefik Dashboard: http://localhost:8080

4. **Test de l'authentification**:
   - Aller sur http://app.localhost
   - Cliquer sur "Login"
   - Connecter MetaMask
   - Signer le message d'authentification
   - Vous êtes maintenant connecté !

## Endpoints API

### Service d'authentification

- `POST /auth/connect` - Connecter un wallet et obtenir un nonce
- `POST /auth/verify` - Vérifier la signature et s'authentifier  
- `POST /auth/logout` - Se déconnecter
- `GET /auth/profile` - Obtenir le profil utilisateur (authentifié)
- `GET /auth/check` - Vérifier l'état d'authentification
- `GET /health` - Health check

## Configuration

### Variables d'environnement

#### Service Auth
- `MONGODB_URI`: URI de connexion MongoDB
- `JWT_SECRET`: Clé secrète pour les tokens JWT
- `CONSUL_HOST`: Hôte Consul
- `CONSUL_PORT`: Port Consul

#### Frontend  
- `VITE_AUTH_API_URL`: URL du service d'authentification
- `VITE_API_URL`: URL de l'API principale

## Développement

### Ajouter un nouveau service

1. Dupliquer le dossier `tuvcb-service-test`
2. Modifier le `package.json` et les fichiers de configuration
3. Ajouter le service dans `docker-compose.yml`
4. Configurer Traefik pour le routage
5. Ajouter la configuration Consul si nécessaire

### Structure d'un service

```
tuvcb-service-*/
├── src/
│   ├── main.ts              # Point d'entrée
│   ├── app.module.ts        # Module principal
│   ├── app.controller.ts    # Contrôleur principal
│   └── app.service.ts       # Service principal
├── Dockerfile               # Image Docker
├── package.json             # Dépendances npm
└── README.md               # Documentation
```

## Sécurité

- Tokens JWT stockés en cookies HTTP-only
- Signatures cryptographiques pour l'authentification  
- CORS configuré pour les domaines autorisés
- Variables d'environnement pour les secrets
- Health checks pour le monitoring

## Monitoring

- Consul pour le service discovery
- Traefik pour le load balancing
- Health checks automatiques
- Logs centralisés par service

---

## 🎯 Rôle du Repository (Configuration originale)

Ce repository a pour objectif de :
- **Configurer Traefik** comme reverse proxy pour router le trafic vers les différents services
- **Déployer Consul** pour la découverte automatique des services
- **Orchestrer l'architecture complète** via Docker Compose
- **Fournir une base d'infrastructure** pour tous les services de l'organisation

## 🏗️ Architecture

L'infrastructure est composée de :

- **Traefik** : Reverse proxy et load balancer
  - Dashboard accessible sur le port 8080
  - Routing automatique basé sur les labels Docker
  - Intégration avec Consul pour la découverte de services

- **Consul** : Service discovery et configuration
  - Interface web sur le port 8500
  - Health checks automatiques
  - Configuration centralisée des services

- **Services applicatifs** : Clonés depuis l'organisation GitHub
  - Chaque service est configuré avec les labels Traefik appropriés
  - Enregistrement automatique dans Consul

## 🚀 Installation et Setup

### Prérequis
- Docker et Docker Compose installés
- Git configuré avec accès à l'organisation **Stick-eth**

### Étapes d'installation

1. **Cloner ce repository d'infrastructure**
   ```bash
   https://github.com/tek-up-vcb/tuvcb-orchestration
   cd tuvcb-orchestration
   ```

2. **Cloner tous les repositories de l'organisation à la racine**
   ```bash
   git clone https://github.com/Stick-eth/tuvcb-front.git
   git clone https://github.com/Stick-eth/backend-api.git
   git clone https://github.com/Stick-eth/service-auth.git
   # ... autres services de l'organisation
   ```

3. **Lancer l'infrastructure complète**
   ```bash
   docker-compose up -d
   ```

4. **Configurer les hosts locaux**
   
   Ajouter les entrées suivantes dans votre fichier `/etc/hosts` (Linux/Mac) ou `C:\Windows\System32\drivers\etc\hosts` (Windows) (en tant qu'admin):
   ```
   127.0.0.1 app.localhost
   127.0.0.1 api1.localhost
   127.0.0.1 api2.localhost
   ```

5. **Vérifier le déploiement**
   ```bash
   docker-compose ps
   ```

## 📋 Services Configurés

Le `docker-compose.yml` configure automatiquement :

### Infrastructure
- **Consul** : `http://localhost:8500`
- **Traefik Dashboard** : `http://localhost:8080`

### Services Applicatifs
- **Frontend** : `http://app.localhost` (port 5173)
- **Service-test** : `http://api.localhost` (port 3000)

## 🔧 Configuration

### Traefik (`traefik/traefik.yml`)
- Point d'entrée HTTP sur le port 80
- Provider Docker pour la découverte automatique
- Provider Consul Catalog pour la configuration dynamique
- API insecure activée pour le développement

### Consul (`consul/config/`)
- Configuration des services avec health checks
- Tags Traefik pour le routing automatique
- Surveillance des endpoints de santé

## 🌐 Routing des Services

Les services sont automatiquement routés via Traefik grâce aux labels Docker :

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.service-name.rule=Host(`subdomain.localhost`)"
  - "traefik.http.services.service-name.loadbalancer.server.port=PORT"
```

## 📁 Structure du Repository

```
tuvcb-orchestration/
├── docker-compose.yml         # Orchestration complète
├── traefik/
│   ├── traefik.yml            # Configuration Traefik
│   └── acme.json              # Certificats SSL (dev)
├── consul/
│   └── config/
│       └── service-test.json  # Configuration service example
├── tuvcb-front/               # Service frontend React
├── tuvcb-service-test/        # Service backend NestJS
└── README.md                  # Ce fichier
```

## 🔍 Monitoring et Debug

### Tableaux de bord
- **Traefik Dashboard** : http://localhost:8080
  - Visualisation des routes actives
  - État des services backend
  - Métriques de trafic

- **Consul UI** : http://localhost:8500
  - Services enregistrés
  - Health checks en temps réel
  - Configuration key-value

### Logs
```bash
# Logs de l'infrastructure
docker-compose logs traefik consul

# Logs de tous les services
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f frontend
```

## 🛠️ Commandes Utiles

```bash
# Démarrer l'infrastructure
docker-compose up -d

# Redémarrer un service
docker-compose restart service-name

# Voir l'état des services
docker-compose ps

# Rebuild et redémarrer
docker-compose up -d --build

# Arrêter l'infrastructure
docker-compose down

# Nettoyer complètement
docker-compose down -v --remove-orphans
```

## 🔄 Ajout de Nouveaux Services

Pour ajouter un nouveau service à l'architecture :

1. **Cloner le repository** à la racine du projet
2. **Ajouter le service** dans `docker-compose.yml` avec les labels Traefik appropriés
3. **Configurer Consul** si nécessaire dans `consul/config/`
4. **Redémarrer** l'infrastructure : `docker-compose up -d`

Exemple de configuration de service :
```yaml
nouveau-service:
  build: ./nouveau-service
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.nouveau.rule=Host(`nouveau.localhost`)"
    - "traefik.http.services.nouveau.loadbalancer.server.port=3000"
  networks:
    - net
```

## 🤝 Contribution

1. Fork le repository
2. Créer une branche feature
3. Ajouter/modifier la configuration d'infrastructure
4. Tester avec `docker-compose up -d`
5. Créer une Pull Request

## 📞 Support

Pour toute question concernant l'infrastructure :
- Ouvrir une issue sur ce repository
- Vérifier les logs avec `docker-compose logs`
- Consulter les dashboards Traefik et Consul