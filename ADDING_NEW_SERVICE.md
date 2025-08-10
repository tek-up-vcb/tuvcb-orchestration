# Guide : Ajouter un nouveau service à l'architecture TUVCB

Ce guide détaille comment ajouter un nouveau service NestJS à l'architecture microservices existante avec Docker, Traefik et Consul.

## Table des matières

1. [Vue d'ensemble de l'architecture](#vue-densemble-de-larchitecture)
2. [Prérequis](#prérequis)
3. [Étape 1 : Créer le service NestJS](#étape-1--créer-le-service-nestjs)
4. [Étape 2 : Configurer Docker](#étape-2--configurer-docker)
5. [Étape 3 : Configurer Traefik](#étape-3--configurer-traefik)
6. [Étape 4 : Ajouter la base de données (optionnel)](#étape-4--ajouter-la-base-de-données-optionnel)
7. [Étape 5 : Intégrer au frontend](#étape-5--intégrer-au-frontend)
8. [Étape 6 : Tester et déboguer](#étape-6--tester-et-déboguer)
9. [Bonnes pratiques](#bonnes-pratiques)

## Vue d'ensemble de l'architecture

L'architecture TUVCB utilise :
- **Frontend React** : Interface utilisateur avec Vite et Shadcn/ui
- **Services NestJS** : API REST microservices
- **PostgreSQL** : Base de données pour chaque service
- **Traefik** : Reverse proxy et load balancer
- **Consul** : Service discovery (configuré mais non utilisé actuellement)
- **Docker Compose** : Orchestration des conteneurs

## Prérequis

- Docker et Docker Compose installés
- Node.js 18+ pour le développement local
- Connaissance de base de NestJS et TypeScript

## Étape 1 : Créer le service NestJS

### 1.1 Initialiser le projet

```bash
# Créer le répertoire du service
mkdir tuvcb-service-[nom-du-service]
cd tuvcb-service-[nom-du-service]

# Initialiser le projet NestJS
npm i -g @nestjs/cli
nest new . --package-manager npm

# Installer les dépendances essentielles
npm install @nestjs/typeorm typeorm pg class-validator class-transformer @nestjs/swagger swagger-ui-express
npm install -D @types/pg
```

### 1.2 Structure de fichiers recommandée

```
tuvcb-service-[nom]/
├── src/
│   ├── app.controller.ts
│   ├── app.module.ts
│   ├── app.service.ts
│   ├── main.ts
│   └── [entity]/
│       ├── [entity].controller.ts
│       ├── [entity].service.ts
│       ├── [entity].module.ts
│       ├── entities/
│       │   └── [entity].entity.ts
│       └── dto/
│           ├── create-[entity].dto.ts
│           └── update-[entity].dto.ts
├── Dockerfile
├── package.json
└── tsconfig.json
```

### 1.3 Configuration du main.ts

```typescript
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // CORS configuration
  app.enableCors({
    origin: ['http://app.localhost', 'http://localhost:3000'],
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
  });

  // Global validation pipe
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  // Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('[Service Name] API')
    .setDescription('API pour la gestion des [entités]')
    .setVersion('1.0')
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT || 3003;
  await app.listen(port);
  console.log(`[Service Name] service running on port ${port}`);
}
bootstrap();
```

### 1.4 Configuration de l'AppModule

```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { [Entity]Module } from './[entity]/[entity].module';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT) || 5432,
      username: process.env.DB_USERNAME || 'postgres',
      password: process.env.DB_PASSWORD || 'password',
      database: process.env.DB_DATABASE || 'service_db',
      entities: [__dirname + '/**/*.entity{.ts,.js}'],
      synchronize: process.env.NODE_ENV === 'development',
      logging: process.env.NODE_ENV === 'development',
    }),
    [Entity]Module,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
```

## Étape 2 : Configurer Docker

### 2.1 Créer le Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer les dépendances
RUN npm ci --only=production

# Copier le code source
COPY . .

# Build de l'application
RUN npm run build

# Exposer le port
EXPOSE 3003

# Commande de démarrage
CMD ["npm", "run", "start:prod"]
```

### 2.2 Ajouter au docker-compose.yml

```yaml
  tuvcb-service-[nom]:
    build:
      context: ./tuvcb-service-[nom]
    environment:
      - SERVICE_NAME=tuvcb-service-[nom]
      - PORT=3003
      - NODE_ENV=development
      - DB_HOST=postgres-[nom]
      - DB_PORT=5432
      - DB_USERNAME=tuvcb_[nom]
      - DB_PASSWORD=tuvcb_password_[nom]
      - DB_DATABASE=tuvcb_[nom]
    networks:
      - net
    depends_on:
      postgres-[nom]:
        condition: service_healthy
      traefik:
        condition: service_started
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.tuvcb-service-[nom].rule=Host(`app.localhost`) && PathPrefix(`/api/[nom]`)"
      - "traefik.http.routers.tuvcb-service-[nom].priority=2000"
      - "traefik.http.services.tuvcb-service-[nom].loadbalancer.server.port=3003"
      - "traefik.http.routers.tuvcb-service-[nom].middlewares=cors@file"

  postgres-[nom]:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: tuvcb_[nom]
      POSTGRES_USER: tuvcb_[nom]
      POSTGRES_PASSWORD: tuvcb_password_[nom]
    volumes:
      - postgres_[nom]_data:/var/lib/postgresql/data
    networks:
      - net
    ports:
      - "5434:5432"  # Port externe unique pour chaque service
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U tuvcb_[nom] -d tuvcb_[nom]"]
      interval: 10s
      timeout: 5s
      retries: 5
```

### 2.3 Ajouter le volume dans docker-compose.yml

```yaml
volumes:
  # ... volumes existants
  postgres_[nom]_data:
```

## Étape 3 : Configurer Traefik

### 3.1 Points importants pour le routage

1. **Priorité** : Les routes API doivent avoir une priorité élevée (2000+) pour être traitées avant la route du frontend
2. **PathPrefix** : Utiliser `/api/[nom-service]` pour éviter les conflits
3. **Middleware CORS** : Ajouter `cors@file` pour les requêtes cross-origin
4. **Port** : Spécifier le port exact du service dans les labels

### 3.2 Vérifier les routes Traefik

```bash
# Vérifier que les routes sont correctement configurées
curl http://localhost:8080/api/http/routers
```

## Étape 4 : Ajouter la base de données (optionnel)

### 4.1 Créer une entité TypeORM

```typescript
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';

export enum UserRole {
  ADMIN = 'Admin',
  TEACHER = 'Teacher',
  GUEST = 'Guest',
}

@Entity('users')
export class User {
  @ApiProperty({ description: 'ID unique de l\'utilisateur' })
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ApiProperty({ description: 'Nom de famille' })
  @Column({ length: 100 })
  nom: string;

  @ApiProperty({ description: 'Prénom' })
  @Column({ length: 100 })
  prenom: string;

  @ApiProperty({ description: 'Rôle de l\'utilisateur', enum: UserRole })
  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.GUEST,
  })
  role: UserRole;

  @ApiProperty({ description: 'Adresse Ethereum de l\'utilisateur' })
  @Column({ unique: true, length: 42 })
  walletAddress: string;

  @ApiProperty({ description: 'Indique si l\'utilisateur est actif' })
  @Column({ default: true })
  isActive: boolean;

  @ApiProperty({ description: 'Date de création' })
  @CreateDateColumn()
  dateCreation: Date;

  @ApiProperty({ description: 'Date de dernière modification' })
  @UpdateDateColumn()
  dateModification: Date;
}
```

### 4.2 Initialisation de données par défaut

Pour ajouter des données initiales à votre service, créez un service de seeding :

```typescript
// src/database/database-seeder.service.ts
import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from '../users/entities/user.entity';

@Injectable()
export class DatabaseSeederService implements OnModuleInit {
  private readonly logger = new Logger(DatabaseSeederService.name);

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async onModuleInit() {
    await this.seedUsers();
  }

  async seedUsers() {
    try {
      this.logger.log('Vérification des utilisateurs par défaut...');

      const defaultUsers = [
        {
          nom: 'Doe',
          prenom: 'John',
          role: UserRole.ADMIN,
          walletAddress: '0x1234567890123456789012345678901234567890',
        },
        // Ajouter d'autres utilisateurs par défaut...
      ];

      for (const userData of defaultUsers) {
        const existingUser = await this.userRepository.findOne({
          where: { walletAddress: userData.walletAddress },
        });

        if (!existingUser) {
          const user = this.userRepository.create(userData);
          await this.userRepository.save(user);
          this.logger.log(`Utilisateur créé: ${userData.prenom} ${userData.nom}`);
        } else {
          this.logger.log(`Utilisateur déjà existant: ${userData.prenom} ${userData.nom}`);
        }
      }

      const totalUsers = await this.userRepository.count();
      this.logger.log(`Nombre total d'utilisateurs: ${totalUsers}`);
    } catch (error) {
      this.logger.error('Erreur lors de l\'initialisation:', error);
    }
  }
}
```

Puis ajoutez-le au module principal :

```typescript
// app.module.ts
import { DatabaseSeederService } from './database/database-seeder.service';
import { User } from './users/entities/user.entity';

@Module({
  imports: [
    // ... autres imports
    TypeOrmModule.forFeature([User]),
  ],
  providers: [AppService, DatabaseSeederService],
})
export class AppModule {}
```

### 4.3 Script SQL d'initialisation (optionnel)

Vous pouvez aussi créer un script SQL pour l'initialisation PostgreSQL :

```sql
-- postgres-init/01-init-[service].sql
\c [database_name];

CREATE TYPE IF NOT EXISTS users_role_enum AS ENUM('Admin', 'Teacher', 'Guest');

CREATE TABLE IF NOT EXISTS "users" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    role users_role_enum DEFAULT 'Guest',
    "walletAddress" VARCHAR(42) UNIQUE NOT NULL,
    "isActive" BOOLEAN DEFAULT true,
    "dateCreation" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "dateModification" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertion conditionnelle de données
INSERT INTO "users" (nom, prenom, role, "walletAddress")
SELECT 'Doe', 'John', 'Admin', '0x1234567890123456789012345678901234567890'
WHERE NOT EXISTS (
    SELECT 1 FROM "users" WHERE "walletAddress" = '0x1234567890123456789012345678901234567890'
);
```

Ajoutez le volume dans docker-compose.yml :

```yaml
postgres-[service]:
  # ... configuration existante
  volumes:
    - postgres_[service]_data:/var/lib/postgresql/data
    - ./postgres-init:/docker-entrypoint-initdb.d:ro
```

## Étape 5 : Intégrer au frontend

### 5.1 Créer un service frontend

```javascript
// src/services/[nom]Service.js
const API_BASE_URL = 'http://app.localhost/api/[nom]';

export const [nom]Service = {
  async getAll() {
    const response = await fetch(`${API_BASE_URL}`);
    if (!response.ok) {
      throw new Error(`Erreur lors de la récupération des [entités]: ${response.statusText}`);
    }
    return response.json();
  },

  async create(data) {
    const response = await fetch(`${API_BASE_URL}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });
    if (!response.ok) {
      throw new Error(`Erreur lors de la création: ${response.statusText}`);
    }
    return response.json();
  },

  async update(id, data) {
    const response = await fetch(`${API_BASE_URL}/${id}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });
    if (!response.ok) {
      throw new Error(`Erreur lors de la mise à jour: ${response.statusText}`);
    }
    return response.json();
  },

  async delete(id) {
    const response = await fetch(`${API_BASE_URL}/${id}`, {
      method: 'DELETE',
    });
    if (!response.ok) {
      throw new Error(`Erreur lors de la suppression: ${response.statusText}`);
    }
    return response.ok;
  },
};
```

### 5.2 Ajouter la navigation (optionnel)

```jsx
// Dans le composant de navigation ou dashboard
import { Link } from 'react-router-dom';

<Link to="/manage-[entités]" className="nav-link">
  Gérer les [entités]
</Link>
```

## Étape 6 : Tester et déboguer

### 6.1 Commandes de test

```bash
# Construire et démarrer le service
docker-compose up -d --build tuvcb-service-[nom]

# Vérifier les logs
docker-compose logs -f tuvcb-service-[nom]

# Tester l'API
curl -X GET http://app.localhost/api/[nom]
curl -X POST http://app.localhost/api/[nom] \
  -H "Content-Type: application/json" \
  -d '{"nom":"test"}'
```

### 6.2 Problèmes courants

1. **Erreur 500 UUID** : Vérifier que les routes ne capturent pas les paramètres incorrects
2. **Routes non trouvées** : Vérifier la priorité Traefik et l'ordre des routes
3. **CORS** : S'assurer que le middleware CORS est configuré
4. **Base de données** : Vérifier que les variables d'environnement sont correctes

### 6.3 Debug des routes Traefik

```bash
# Voir toutes les routes configurées
curl http://localhost:8080/api/http/routers | jq '.[].rule'

# Vérifier les services
curl http://localhost:8080/api/http/services
```

## Bonnes pratiques

### 6.1 Nommage

- Services : `tuvcb-service-[nom-descriptif]`
- Base de données : `postgres-[nom-service]`
- Routes : `/api/[nom-service]`
- Ports : Incrémenter de 1 pour chaque nouveau service

### 6.2 Sécurité

- Utiliser des variables d'environnement pour les secrets
- Valider toutes les entrées avec class-validator
- Implémenter l'authentification si nécessaire

### 6.3 Documentation

- Configurer Swagger pour chaque service
- Documenter les DTOs avec @ApiProperty
- Maintenir ce guide à jour

### 6.4 Tests

```bash
# Tester l'intégration complète
npm run test:e2e

# Tester les contrôleurs
npm run test
```

## Exemple complet : Service "Products"

Voici un exemple concret d'ajout d'un service de gestion de produits :

1. **Nom du service** : `tuvcb-service-products`
2. **Port** : 3004
3. **Base de données** : `postgres-products` (port 5435)
4. **Route** : `/api/products`
5. **Entité** : Product avec nom, description, prix

Cette structure garantit une architecture cohérente et évolutive pour l'ensemble du projet TUVCB.

## Support

Pour toute question ou problème, consulter :
- Les logs Docker : `docker-compose logs [service-name]`
- Dashboard Traefik : http://localhost:8080
- Documentation Swagger de chaque service : http://app.localhost/api/[service]/docs

## Historique des services

### Services existants

1. **tuvcb-service-auth** (Port 3001)
   - Authentification Web3 avec MetaMask
   - Route : `/api/auth`
   - JWT et validation d'adresse Ethereum

2. **tuvcb-service-test** (Port 3002)  
   - Service de test et développement
   - Route : `/api/test`
   - Tests d'intégration

3. **tuvcb-service-users** (Port 3003)
   - Gestion CRUD des utilisateurs
   - Route : `/api/users`
   - Base de données PostgreSQL dédiée

4. **tuvcb-service-auth** (Port 3001) ⭐ **Mis à jour**
   - Authentification Web3 avec MetaMask
   - Route : `/api/auth`
   - **Nouvelle fonctionnalité** : Authentification basée sur la base de données users
   - Seules les adresses présentes dans la table `users` avec `isActive=true` peuvent se connecter
   - Comparaison d'adresses case-insensitive pour la compatibilité
   - JWT enrichi avec les informations utilisateur (nom, prénom, rôle)

### Prochains ports disponibles

- **3004** : Disponible pour le prochain service
- **5435** : Port PostgreSQL pour le prochain service

## Authentification et sécurité

### Configuration de l'authentification basée sur la base de données

Le système d'authentification TUVCB utilise MetaMask pour l'authentification Web3, mais vérifie que l'adresse wallet est autorisée via la base de données users.

#### Fonctionnement :
1. **Génération de nonce** : L'utilisateur demande un nonce via `/api/auth/nonce`
2. **Signature MetaMask** : L'utilisateur signe le message avec MetaMask
3. **Vérification** : Le service auth vérifie la signature ET que l'adresse existe dans la table `users` avec `isActive=true`
4. **JWT** : Si valide, un JWT est généré avec les informations utilisateur (nom, prénom, rôle)

#### Configuration du service auth :
```typescript
// Variables d'environnement requises
DB_HOST=postgres
DB_PORT=5432
DB_USERNAME=tuvcb_user
DB_PASSWORD=tuvcb_password
DB_DATABASE=tuvcb_users
```

#### Points clés :
- **Sécurité** : Seules les adresses en base de données peuvent se connecter
- **Compatibilité** : Comparaison case-insensitive des adresses Ethereum
- **Flexibilité** : Possibilité de désactiver un utilisateur via `isActive=false`
- **Enrichissement** : JWT contient les informations utilisateur pour les autres services

Cette documentation a été créée le 10 août 2025 et reflète l'état actuel de l'architecture TUVCB.
