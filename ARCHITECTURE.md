# TUVCB - Architecture Microservices

## Services disponibles

### 1. Frontend (tuvcb-front)
- **Port**: 5173
- **URL**: http://app.localhost
- **Description**: Interface utilisateur React avec Vite
- **Fonctionnalités**:
  - Authentification MetaMask
  - Dashboard utilisateur
  - Gestion des utilisateurs (CRUD)

### 2. Service d'authentification (tuvcb-service-auth)
- **Port**: 3001
- **URL**: http://app.localhost/api/auth
- **Description**: Service NestJS pour l'authentification Web3
- **Fonctionnalités**:
  - Authentification par signature MetaMask
  - Génération de tokens JWT
  - Validation des adresses Ethereum

### 3. Service utilisateurs (tuvcb-service-users) ⭐ NOUVEAU
- **Port**: 3002
- **URL**: http://app.localhost/api/users
- **Description**: Service NestJS pour la gestion des utilisateurs
- **Fonctionnalités**:
  - CRUD complet des utilisateurs
  - Validation des adresses Ethereum
  - Gestion des rôles (Admin, Teacher, Guest)
  - API REST avec documentation Swagger

### 4. Service de test (tuvcb-service-test)
- **Port**: 3000
- **URL**: http://app.localhost/api/test
- **Description**: Service de test pour les autres composants

### 5. Base de données PostgreSQL ⭐ NOUVEAU
- **Port**: 5432
- **Base de données**: tuvcb_users
- **Utilisateur**: tuvcb_user
- **Description**: Base de données relationnelle pour stocker les utilisateurs

## Infrastructure

### Traefik (Load Balancer & Reverse Proxy)
- **Dashboard**: http://localhost:8080
- **Configuration**: 
  - Routage par nom de domaine et chemin
  - Middlewares CORS et strip-prefix
  - Load balancing automatique

### Consul (Service Discovery)
- **Dashboard**: http://localhost:8500
- **Configuration**:
  - Enregistrement automatique des services
  - Health checks
  - Configuration centralisée

## Flux de données

```
Frontend (React)
    ↓ HTTP Requests
Traefik (Reverse Proxy)
    ↓ Route par chemin
Services NestJS
    ↓ TypeORM
PostgreSQL Database
```

## API Endpoints

### Service Users (/api/users)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/users` | Récupérer tous les utilisateurs |
| `GET` | `/users/:id` | Récupérer un utilisateur par ID |
| `GET` | `/users/wallet/:address` | Récupérer un utilisateur par adresse wallet |
| `GET` | `/users/count` | Compter les utilisateurs |
| `POST` | `/users` | Créer un nouvel utilisateur |
| `PATCH` | `/users/:id` | Mettre à jour un utilisateur |
| `DELETE` | `/users/:id` | Supprimer un utilisateur |

### Documentation Swagger
- **Users Service**: http://app.localhost/api/users/docs

## Déploiement

### Développement
```bash
# Démarrer tous les services
docker-compose up -d --build

# Voir les logs
docker-compose logs -f

# Arrêter tous les services
docker-compose down
```

### Variables d'environnement

#### Service Users
- `DB_HOST`: Hôte PostgreSQL
- `DB_PORT`: Port PostgreSQL (5432)
- `DB_USERNAME`: Nom d'utilisateur DB
- `DB_PASSWORD`: Mot de passe DB
- `DB_DATABASE`: Nom de la base de données

## Sécurité

### Base de données
- Utilisateur dédié avec permissions limitées
- Mot de passe sécurisé
- Isolation réseau Docker

### APIs
- Validation des données d'entrée
- Gestion d'erreurs appropriée
- Validation des adresses Ethereum

### Infrastructure
- Services isolés dans des conteneurs
- Communication via réseau Docker privé
- Exposition contrôlée via Traefik

## Monitoring

### Health Checks
- PostgreSQL: `pg_isready`
- Services NestJS: `/health` endpoint
- Consul: Health checks automatiques

### Logs
```bash
# Logs d'un service spécifique
docker-compose logs tuvcb-service-users

# Logs en temps réel
docker-compose logs -f
```

## Prochaines étapes

1. **Authentification inter-services**: JWT entre services
2. **Middleware d'autorisation**: Contrôle d'accès basé sur les rôles
3. **Cache Redis**: Pour améliorer les performances
4. **Monitoring avancé**: Prometheus + Grafana
5. **Tests d'intégration**: Tests E2E complets
