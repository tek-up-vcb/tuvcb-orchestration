# Gestion des Étudiants - Documentation

## Vue d'ensemble

Ce document décrit l'implémentation de la fonctionnalité de gestion des étudiants dans l'application TUVCB. Cette fonctionnalité permet de gérer des étudiants qui ne sont pas des utilisateurs de la plateforme, organisés en promotions.

## Architecture

### Backend (NestJS + TypeORM + PostgreSQL)

#### Entités

**1. Promotion (`src/students/entities/promotion.entity.ts`)**
- `id`: UUID (auto-généré)
- `nom`: String unique (ex: "Promo25", "Externes2024")
- `description`: String optionnel
- `annee`: Integer (année de la promotion)
- `isActive`: Boolean (statut actif/inactif)
- `dateCreation`: Date automatique
- `dateModification`: Date automatique
- `students`: Relation OneToMany vers Student

**2. Student (`src/students/entities/student.entity.ts`)**
- `id`: UUID (auto-généré)
- `studentId`: String unique (ID étudiant manuel)
- `nom`: String
- `prenom`: String
- `email`: String unique
- `promotionId`: UUID (clé étrangère)
- `promotion`: Relation ManyToOne vers Promotion
- `isActive`: Boolean
- `dateCreation`: Date automatique
- `dateModification`: Date automatique

#### Services

**1. StudentsService (`src/students/students.service.ts`)**
- `create()`: Créer un nouvel étudiant
- `findAll()`: Récupérer tous les étudiants
- `findByPromotion()`: Filtrer par promotion
- `findOne()`: Récupérer par ID
- `findByStudentId()`: Récupérer par ID étudiant
- `findByEmail()`: Récupérer par email
- `update()`: Mettre à jour un étudiant
- `remove()`: Supprimer un étudiant
- `count()`: Compter les étudiants

**2. PromotionsService (`src/students/promotions.service.ts`)**
- `create()`: Créer une nouvelle promotion
- `findAll()`: Récupérer toutes les promotions
- `findActive()`: Récupérer les promotions actives
- `findOne()`: Récupérer par ID
- `update()`: Mettre à jour une promotion
- `remove()`: Supprimer une promotion
- `count()`: Compter les promotions

#### Contrôleurs

**1. StudentsController (`src/students/students.controller.ts`)**
- `POST /api/students`: Créer un étudiant
- `GET /api/students`: Lister les étudiants (avec filtre par promotion)
- `GET /api/students/:id`: Récupérer un étudiant
- `GET /api/students/student-id/:studentId`: Récupérer par ID étudiant
- `GET /api/students/email/:email`: Récupérer par email
- `GET /api/students/count`: Compter les étudiants
- `PATCH /api/students/:id`: Mettre à jour un étudiant
- `DELETE /api/students/:id`: Supprimer un étudiant

**2. PromotionsController (`src/students/promotions.controller.ts`)**
- `POST /api/promotions`: Créer une promotion
- `GET /api/promotions`: Lister les promotions
- `GET /api/promotions/active`: Lister les promotions actives
- `GET /api/promotions/:id`: Récupérer une promotion
- `GET /api/promotions/count`: Compter les promotions
- `PATCH /api/promotions/:id`: Mettre à jour une promotion
- `DELETE /api/promotions/:id`: Supprimer une promotion

#### DTOs

**CreateStudentDto:**
```typescript
{
  studentId: string;    // ID étudiant unique
  nom: string;          // Nom de famille
  prenom: string;       // Prénom
  email: string;        // Email unique
  promotionId: string;  // UUID de la promotion
}
```

**CreatePromotionDto:**
```typescript
{
  nom: string;          // Nom unique de la promotion
  description?: string; // Description optionnelle
  annee: number;        // Année (>= 2020)
}
```

### Frontend (React + Vite)

#### Services

**1. StudentsService (`src/services/studentsService.js`)**
- Gestion complète des appels API pour les étudiants
- Méthodes CRUD + recherche et filtrage

**2. PromotionsService (`src/services/promotionsService.js`)**
- Gestion des appels API pour les promotions
- Méthodes CRUD + récupération des promotions actives

#### Pages

**ManageStudents (`src/pages/manage-students.jsx`)**
- Interface complète de gestion des étudiants et promotions
- Fonctionnalités :
  - Création/modification/suppression d'étudiants
  - Création/modification des promotions
  - Filtrage des étudiants par promotion
  - Validation des formulaires
  - Gestion des erreurs

#### Fonctionnalités de l'interface

**Section Promotions :**
- Affichage en cartes des promotions existantes
- Création de nouvelles promotions avec nom, description et année
- Modification des promotions existantes
- Compteur d'étudiants par promotion
- Badges colorés selon l'année (actuelle/future/passée)

**Section Étudiants :**
- Tableau complet avec toutes les informations
- Filtrage par promotion via dropdown
- Création d'étudiants avec validation :
  - ID étudiant unique
  - Email unique
  - Association à une promotion
- Modification des étudiants existants
- Suppression avec confirmation
- Recherche et tri

## Validation et Sécurité

### Backend
- Validation avec `class-validator`
- Contraintes d'unicité en base de données
- Vérification de l'existence des relations
- Gestion des erreurs avec messages explicites

### Frontend
- Validation des formulaires côté client
- Gestion des erreurs serveur
- Confirmation pour les suppressions
- Feedback utilisateur en temps réel

## Base de données

### Tables créées
- `promotions` : Stockage des promotions
- `students` : Stockage des étudiants avec référence à la promotion

### Relations
- `students.promotionId` → `promotions.id` (ManyToOne)

## Installation et Démarrage

1. **Backend** : Les nouvelles entités et modules sont automatiquement inclus dans `app.module.ts`
2. **Frontend** : La nouvelle route `/manage-students` est ajoutée à `App.jsx`
3. **Navigation** : Un bouton "Gérer les étudiants" est ajouté au dashboard

## URLs d'accès

- **Page de gestion** : `http://localhost/manage-students`
- **API Backend** :
  - Étudiants : `http://localhost/api/students`
  - Promotions : `http://localhost/api/promotions`

## Exemples de données

**Promotion :**
```json
{
  "nom": "Promo25",
  "description": "Promotion 2025 - Développement Web",
  "annee": 2025
}
```

**Étudiant :**
```json
{
  "studentId": "ETU2025001",
  "nom": "Dupont",
  "prenom": "Jean",
  "email": "jean.dupont@example.com",
  "promotionId": "uuid-de-la-promotion"
}
```

Cette implémentation offre une solution complète pour la gestion des étudiants avec une interface utilisateur intuitive et une API robuste.
