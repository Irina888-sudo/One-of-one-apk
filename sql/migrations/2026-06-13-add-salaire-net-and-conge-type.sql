-- Migration: add salaire_net and jours_conges to salaire, and type_conge to conge
-- Backup your DB before applying.

ALTER TABLE conge
  ADD COLUMN IF NOT EXISTS type_conge ENUM('PAYE','NON_PAYE') DEFAULT 'NON_PAYE';

ALTER TABLE salaire
  ADD COLUMN IF NOT EXISTS salaire_net DECIMAL(10,2) DEFAULT 0.00,
  ADD COLUMN IF NOT EXISTS jours_conges INT DEFAULT 0;

-- Optionally initialize salaire_net to salaire_brut for existing rows
UPDATE salaire SET salaire_net = salaire_brut WHERE salaire_net IS NULL OR salaire_net = 0;
