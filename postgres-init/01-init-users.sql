-- Initialization script for tuvcb_main database

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (existing)
-- This table is managed by the auth and users services

-- Students table (existing)
-- This table is managed by the users service

-- Promotions table (existing)
-- This table is managed by the users service

-- New tables for diploma management

-- Diplomas table
CREATE TABLE IF NOT EXISTS diplomas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    level VARCHAR(100) NOT NULL,
    field VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Diploma requests table
CREATE TABLE IF NOT EXISTS diploma_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    diploma_id UUID NOT NULL REFERENCES diplomas(id) ON DELETE CASCADE,
    created_by UUID NOT NULL,
    student_ids TEXT[] NOT NULL,
    comment TEXT,
    required_signatures TEXT[] NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    valid_signatures INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Diploma request signatures table
CREATE TABLE IF NOT EXISTS diploma_request_signatures (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    diploma_request_id UUID NOT NULL REFERENCES diploma_requests(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    is_signed BOOLEAN DEFAULT false,
    signed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    signature_comment TEXT
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_diploma_requests_created_by ON diploma_requests(created_by);
CREATE INDEX IF NOT EXISTS idx_diploma_requests_status ON diploma_requests(status);
CREATE INDEX IF NOT EXISTS idx_diploma_signatures_request_id ON diploma_request_signatures(diploma_request_id);
CREATE INDEX IF NOT EXISTS idx_diploma_signatures_user_id ON diploma_request_signatures(user_id);

-- Insert some sample diplomas
INSERT INTO diplomas (name, description, level, field) VALUES
('Diplôme d''Ingénieur Informatique', 'Diplôme d''ingénieur en informatique et technologies numériques', 'Master', 'Informatique'),
('License en Informatique', 'License professionnelle en informatique', 'License', 'Informatique'),
('Master en Data Science', 'Master spécialisé en science des données', 'Master', 'Data Science'),
('Certificat DevOps', 'Certificat professionnel en DevOps et intégration continue', 'Certificat', 'DevOps')
ON CONFLICT DO NOTHING;
-- Ce script sera exécuté automatiquement lors du premier démarrage de PostgreSQL

-- Se connecter à la base de données main
\c tuvcb_main;

-- Créer l'enum pour les rôles si il n'existe pas
DO $$ BEGIN
    CREATE TYPE users_role_enum AS ENUM('Admin', 'Teacher', 'Guest');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Créer la table users si elle n'existe pas (normalement créée par TypeORM)
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

-- Fonction pour insérer un utilisateur seulement s'il n'existe pas déjà
CREATE OR REPLACE FUNCTION insert_user_if_not_exists(
    p_nom VARCHAR,
    p_prenom VARCHAR,
    p_role users_role_enum,
    p_wallet_address VARCHAR
) RETURNS VOID AS $$
BEGIN
    -- Vérifier si l'utilisateur existe déjà (par adresse Ethereum)
    IF NOT EXISTS (SELECT 1 FROM "users" WHERE "walletAddress" = p_wallet_address) THEN
        INSERT INTO "users" (nom, prenom, role, "walletAddress")
        VALUES (p_nom, p_prenom, p_role, p_wallet_address);
        
        RAISE NOTICE 'Utilisateur créé: % % (%) - %', p_prenom, p_nom, p_role, p_wallet_address;
    ELSE
        RAISE NOTICE 'Utilisateur déjà existant: % % - %', p_prenom, p_nom, p_wallet_address;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Insérer les utilisateurs par défaut
DO $$
BEGIN
    RAISE NOTICE 'Début de l''initialisation des utilisateurs par défaut...';
    
    -- Insérer Aniss Sejean
    PERFORM insert_user_if_not_exists(
        'Sejean',
        'Aniss', 
        'Admin'::users_role_enum,
        '0xD498fd6BCd7D152319a3e822b83a9610710655eC'
    );
    
    -- Insérer Timéo Hamlil-Benard
    PERFORM insert_user_if_not_exists(
        'Hamlil-Benard',
        'Timéo',
        'Admin'::users_role_enum, 
        '0xF54Be8cf7076A7C1222B39bf5Ee329aB4695CAB5'
    );
    
    RAISE NOTICE 'Initialisation des utilisateurs terminée.';
END $$;

-- Afficher le nombre total d'utilisateurs
DO $$
DECLARE
    user_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM "users";
    RAISE NOTICE 'Nombre total d''utilisateurs dans la base: %', user_count;
END $$;

-- Supprimer la fonction temporaire
DROP FUNCTION insert_user_if_not_exists(VARCHAR, VARCHAR, users_role_enum, VARCHAR);
