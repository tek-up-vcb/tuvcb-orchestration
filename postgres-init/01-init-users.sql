-- Script d'initialisation pour la base de données users
-- Ce script sera exécuté automatiquement lors du premier démarrage de PostgreSQL

-- Se connecter à la base de données users
\c tuvcb_users;

-- Créer l'enum pour les rôles si il n'existe pas
CREATE TYPE IF NOT EXISTS users_role_enum AS ENUM('Admin', 'Teacher', 'Guest');

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
