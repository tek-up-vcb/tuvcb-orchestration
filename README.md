# TUVCB - Plateforme Blockchain Décentralisée

## Présentation

Ce dépôt configure l’infrastructure de la plateforme Web3 **TUVCB**. Il se compose d’un ensemble de conteneurs Docker définis dans `docker-compose.yml`. Les conteneurs déployés incluent :

- un **frontend React** pour l’interface utilisateur,
- un service **Auth** pour l’authentification MetaMask,
- un service **Users** pour la gestion CRUD des utilisateurs et étudiants,
- un service **Diplomas** pour les modèles et demandes de diplômes,
- un micro-service **Blockchain** pour interagir avec le contrat `DiplomaRegistry`,
- les composants d’infrastructure : base de données PostgreSQL, service discovery **Consul**, reverse proxy **Traefik**, et la stack de monitoring **Prometheus/Grafana**.

Cette orchestration fournit donc un socle complet permettant à l’ensemble de la plateforme de fonctionner de manière cohérente.

## Prérequis

- [Docker](https://docs.docker.com/get-docker/) et Docker Compose installés.
- Git configuré avec accès aux dépôts de l’organisation.
- Système permettant de modifier le fichier `etc/hosts` (ou `C:\\Windows\\System32\\drivers\\etc\\hosts` sous Windows).

## Installation

1. **Cloner le dépôt d’orchestration** :

   ```bash
   git clone https://github.com/tek-up-vcb/tuvcb-orchestration
   cd tuvcb-orchestration
   ```

2. **Cloner les services applicatifs**  
   Placez-vous dans le répertoire racine et clonez chaque dépôt. Dans l’exemple ci-dessous on clone le front et les micro-services ; adaptez selon les dépôts réellement utilisés :

   ```bash
   git clone https://github.com/tek-up-vcb/tuvcb-front.git
   git clone https://github.com/tek-up-vcb/tuvcb-service-auth.git
   git clone https://github.com/tek-up-vcb/tuvcb-service-users.git
   git clone https://github.com/tek-up-vcb/tuvcb-service-diploma.git
   git clone https://github.com/tek-up-vcb/tuvcb-blockchain.git
   ```

3. **Configurer le fichier hosts**  
   Pour profiter des sous-domaines utilisés par Traefik, ajoutez les lignes suivantes à votre fichier `hosts` (en privilège administrateur) :

   ```
   127.0.0.1 app.localhost
   127.0.0.1 traefik.localhost
   127.0.0.1 monitoring.localhost
   ```

4. **Lancer l’infrastructure**  
   Démarrez tous les conteneurs en arrière-plan :

   ```bash
   docker-compose up -d
   ```

5. **Vérifier le déploiement** :

   ```bash
   docker-compose ps
   ```

## Services exposés

Les principaux services sont exposés via **Traefik** et accessibles via des sous-domaines locaux. Le tableau ci-dessous résume les rôles et ports :

| Service            | Sous-domaine / Port                                         | Rôle                                  |
| ------------------ | ----------------------------------------------------------- | ------------------------------------- |
| Traefik dashboard  | `traefik.localhost` (8080)                                  | configuration et état du proxy        |
| Consul             | `http://localhost:8500`                                     | découverte de services et KV store    |
| PostgreSQL         | `localhost:5432`                                            | base de données partagée              |
| Frontend (React)   | `app.localhost` (5173)                                      | interface utilisateur                 |
| Auth service       | routé sous `/api/auth`                                      | authentification Web3                 |
| Users service      | routé sous `/api/users`, `/api/students`, `/api/promotions` | gestion des utilisateurs et étudiants |
| Diploma service    | routé sous `/api/diplomas`                                  | modèles et demandes de diplômes       |
| Blockchain service | routé sous `/api/blockchain`                                | interaction avec le smart-contract    |
| Prometheus         | `monitoring.localhost/prometheus` (9090)                    | collecte des métriques                |
| Grafana            | `monitoring.localhost/grafana` (3001)                       | tableaux de bord (admin/admin)        |
| Node Exporter      | `http://localhost:9100`                                     | métriques système                     |
| cAdvisor           | `http://localhost:8081`                                     | métriques des conteneurs              |

## Configuration des services applicatifs

Chaque micro-service est paramétré via des variables d’environnement définies dans `docker-compose.yml`. Pour un déploiement personnalisé, créez un fichier `.env` et surcharger les valeurs suivantes :

### Base de données

```env
POSTGRES_DB=tuvcb_main
POSTGRES_USER=tuvcb_user
POSTGRES_PASSWORD=tuvcb_password
```

Ces variables sont utilisées par le conteneur `postgres`.

### Users service (port 3002)

```env
PORT=3002
NODE_ENV=development
DB_HOST=postgres
DB_PORT=5432
DB_USERNAME=tuvcb_user
DB_PASSWORD=tuvcb_password
DB_DATABASE=tuvcb_main
```

Ce service est exposé via Traefik avec la règle :

```
Host(`app.localhost`) && (PathPrefix(`/api/users`) || PathPrefix(`/api/students`) || PathPrefix(`/api/promotions`))
```

### Auth service (port 3001)

```env
PORT=3001
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=24h
NODE_ENV=development
DB_HOST=postgres
DB_PORT=5432
DB_USERNAME=tuvcb_user
DB_PASSWORD=tuvcb_password
DB_DATABASE=tuvcb_main
```

Le service est routé sous `/api/auth`.

### Diploma service (port 3003)

```env
PORT=3003
NODE_ENV=development
DB_HOST=postgres
DB_PORT=5432
DB_USERNAME=tuvcb_user
DB_PASSWORD=tuvcb_password
DB_DATABASE=tuvcb_main
```

Routé sous `/api/diplomas`.

### Blockchain service (port 3000)

```env
PORT=3000
RPC_URL=http://hardhat-node:8545
PRIVATE_KEY=0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
```

Routé sous `/api/blockchain`. Ce service dépend d’un nœud Hardhat local exposé sur 8545.

## Supervision et monitoring

La plateforme fournit une stack de monitoring complète :

- **Prometheus** collecte les métriques des services et des conteneurs. Elle est accessible via `monitoring.localhost/prometheus`.
- **Grafana** affiche des tableaux de bord ; la page se trouve sur `monitoring.localhost/grafana` et l’accès initial se fait avec le couple `admin/admin`.
- **Node Exporter** et **cAdvisor** exposent les métriques système et conteneur qui sont récupérées par Prometheus.
- Un script `start-monitoring.ps1` permet de lancer uniquement la stack de monitoring.

## Commandes utiles

Quelques commandes pour gérer l’infrastructure :

```bash
docker-compose up -d               # démarrer l’ensemble
docker-compose restart <service>   # redémarrer un service
docker-compose ps                  # voir l’état des services
docker-compose logs -f <service>   # suivre les logs d’un service
docker-compose up -d --build       # reconstruire les images et redémarrer
```

## Ajout de nouveaux services

Pour ajouter un micro-service à cette architecture :

1. Clonez le service dans la racine du dépôt.
2. Assurez-vous qu’il expose un port interne et définissez les variables d’environnement nécessaires.
3. Ajoutez des labels Traefik pour le routing, par exemple :

   ```yaml
   labels:
     - "traefik.enable=true"
     - "traefik.http.routers.service-name.rule=Host(`subdomain.localhost`)"
     - "traefik.http.services.service-name.loadbalancer.server.port=PORT"
   ```

4. Déclarez éventuellement le service dans Consul (`consul/config/`) pour les health checks et la configuration dynamique.

Cette orchestration fournit ainsi une base prête à l’emploi pour la plateforme TUVCB.

## 📞 Support

Pour toute question concernant l'infrastructure :
- Ouvrir une issue sur ce repository
- Vérifier les logs avec `docker-compose logs`
- Consulter les dashboards Traefik et Consul
