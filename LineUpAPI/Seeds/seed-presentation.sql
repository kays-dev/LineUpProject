-- =============================================================================
-- LineUpAPI : jeu de données de la PRÉSENTATION (seed-presentation)
-- -----------------------------------------------------------------------------
-- À exécuter dans phpMyAdmin, sur la base `lineup`, APRÈS `swift run LineUpAPI migrate`.
-- On peut le relancer autant de fois qu'on veut : il VIDE les 4 tables puis remet
-- les mêmes données.
--
-- ⚠️ Il supprime TOUTES les données de ces tables, y compris les comptes et
--    réservations créés à la main (Postman, app). Ne pas l'exécuter en production.
--
-- Dates écrites en dur : du lundi 2 au vendredi 6 novembre 2026, quel que soit
-- le jour où on lance le script (le seed.sql, lui, part du jour où on le lance).
--   2 créneaux qui s'enchaînent, heure de Paris : 08:30-12:30 et 12:30-18:30.
--   Les heures sont écrites en UTC (comme Vapor les enregistre) : Paris = UTC+1 en hiver.
--
-- Descriptions découpées en sections pour l'app : « Nom|détail » séparées par « § »
--   (Description, Lieu, Consigne PSH, Liste d’attente, Point de RDV).
--   Pas de « | » ni de « § » dans les textes, sinon la section est ignorée.
--
-- Comptes : Admin (staff) admin@lineup.com, mot de passe partagé par Krystal.
--           20 festivaliers prenom.nom@lineup.com, mot de passe : festival26.
--           Compte de démo : giulia.bianchi@lineup.com
-- =============================================================================

-- 1. Vider les tables, dans l'ordre imposé par les clés étrangères
DELETE FROM reservations;
DELETE FROM workshops;
DELETE FROM categories;
DELETE FROM users;
ALTER TABLE reservations AUTO_INCREMENT = 1;

-- Jour 1 = lundi 2 novembre 2026, écrit en dur
SET @d0 = DATE('2026-11-02');

-- 2. Utilisateurs : 1 staff + 20 festivaliers (id fixes, identiques chez tout le monde)
INSERT INTO users (id, name, email, password_hash, role, created_at) VALUES
  (UNHEX('AD000000000000000000000000000001'), 'Admin', 'admin@lineup.com', '$2b$12$.7NvdJ0WscbhyVRooEQ2UeO5ANm2Rg2bG.FBBGj0z1L6VnZGxS.ia', 'staff', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000001'), 'Giulia Bianchi', 'giulia.bianchi@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000002'), 'Marco Rossi', 'marco.rossi@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000003'), 'Luca Romano', 'luca.romano@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000004'), 'Sofia Ricci', 'sofia.ricci@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000005'), 'Alessandro Conti', 'alessandro.conti@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000006'), 'Francesca Greco', 'francesca.greco@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000007'), 'Matteo Bruno', 'matteo.bruno@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000008'), 'Chiara Gallo', 'chiara.gallo@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000009'), 'Lorenzo Costa', 'lorenzo.costa@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000010'), 'Valentina Fontana', 'valentina.fontana@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000011'), 'Andrea Moretti', 'andrea.moretti@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000012'), 'Elena Marino', 'elena.marino@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000013'), 'Davide Rinaldi', 'davide.rinaldi@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000014'), 'Martina Lombardi', 'martina.lombardi@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000015'), 'Simone Ferrari', 'simone.ferrari@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000016'), 'Sara Colombo', 'sara.colombo@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000017'), 'Federico Esposito', 'federico.esposito@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000018'), 'Alessia Barbieri', 'alessia.barbieri@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000019'), 'Riccardo Santoro', 'riccardo.santoro@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP()),
  (UNHEX('10000000000000000000000000000020'), 'Beatrice De Luca', 'beatrice.deluca@lineup.com', '$2b$12$.Y.X.WWnyH4ay5lS7lndweSNd3jVbuMYMAFONVfq5vCXoHRnEY/36', 'festivalgoer', UTC_TIMESTAMP());

-- 3. Catégories
INSERT INTO categories (id, name) VALUES
  (UNHEX('CA000000000000000000000000000001'), 'Théâtre'),
  (UNHEX('CA000000000000000000000000000002'), 'Cinéma'),
  (UNHEX('CA000000000000000000000000000003'), 'Jeune public'),
  (UNHEX('CA000000000000000000000000000004'), 'Musique & danse'),
  (UNHEX('CA000000000000000000000000000005'), 'Photo'),
  (UNHEX('CA000000000000000000000000000006'), 'Culture & patrimoine');

-- 4. Ateliers : 2 par jour pendant 5 jours (subscriber_number recalculé à l'étape 6)
INSERT INTO workshops (id, name, start_time, end_time, capacity_max, subscriber_number, description, category_id) VALUES
  -- Jour 1, matin
  (UNHEX('EE000000000000000000000000000001'), 'Éternel Tintoret', TIMESTAMP(@d0 + INTERVAL 0 DAY, '07:30:00'), TIMESTAMP(@d0 + INTERVAL 0 DAY, '11:30:00'), 10, 0, 'Description|L’atelier Éternel Tintoret invite à redécouvrir l’art des grands maîtres vénitiens à travers l’objectif photographique. Guidés par un photographe, les participants explorent la lumière dramatique, les contrastes et les cadrages audacieux qui ont fait la force du Tintoret, avant de réaliser leurs propres portraits. Une expérience créative et accessible, où la peinture de la Renaissance devient une source d’inspiration pour l’image d’aujourd’hui.§Lieu|Galerie Canaletto§Consigne PSH|Atelier accessible en fauteuil roulant. Tabourets disponibles sur demande.§Liste d’attente|Vous êtes sur liste d’attente : si une place se libère, elle vous est attribuée automatiquement et vous recevez une notification.§Point de RDV|Accueil de la Galerie Canaletto, 15 minutes avant le début.', UNHEX('CA000000000000000000000000000005')),
  -- Jour 1, après-midi
  (UNHEX('EE000000000000000000000000000002'), 'L''atelier des enfants', TIMESTAMP(@d0 + INTERVAL 0 DAY, '11:30:00'), TIMESTAMP(@d0 + INTERVAL 0 DAY, '17:30:00'), 20, 0, 'Description|L’atelier des enfants propose aux 6-12 ans un voyage créatif au cœur de la tradition italienne, entre masques vénitiens, couleurs éclatantes et collages joyeux. Accompagnés par des animateurs, les jeunes artistes imaginent, découpent et décorent leurs propres créations en laissant libre cours à leur fantaisie. Un moment ludique et convivial, pour éveiller la curiosité des plus petits et repartir avec une œuvre faite de leurs mains.§Lieu|Atelier des Arts§Consigne PSH|Salle de plain-pied. Un animateur formé à l’accueil des enfants en situation de handicap est présent.§Liste d’attente|Vous êtes sur liste d’attente : si une place se libère, elle vous est attribuée automatiquement et vous recevez une notification.§Point de RDV|Devant l’Atelier des Arts, les enfants restent avec un adulte jusqu’au début.', UNHEX('CA000000000000000000000000000003')),
  -- Jour 2, matin
  (UNHEX('EE000000000000000000000000000003'), 'Ville Lumière ou Città Eterna', TIMESTAMP(@d0 + INTERVAL 1 DAY, '07:30:00'), TIMESTAMP(@d0 + INTERVAL 1 DAY, '11:30:00'), 30, 0, 'Description|Ville Lumière ou Città Eterna est une balade commentée qui fait dialoguer Paris et Rome, deux capitales unies par des siècles d’échanges artistiques et culturels. Au fil des monuments, un guide raconte les influences croisées, les artistes voyageurs et les histoires qui relient les bords de Seine aux rives du Tibre. Une promenade vivante et instructive, pour regarder la ville autrement et y retrouver un peu d’Italie.§Lieu|Parvis de l’Hôtel de Ville§Consigne PSH|Parcours de 3 km sans escaliers. Casques audio amplifiés disponibles.§Liste d’attente|Vous êtes sur liste d’attente : si une place se libère, elle vous est attribuée automatiquement et vous recevez une notification.§Point de RDV|Parvis de l’Hôtel de Ville, sous le drapeau du festival.', UNHEX('CA000000000000000000000000000006')),
  -- Jour 2, après-midi
  (UNHEX('EE000000000000000000000000000004'), 'La dolce vita', TIMESTAMP(@d0 + INTERVAL 1 DAY, '11:30:00'), TIMESTAMP(@d0 + INTERVAL 1 DAY, '17:30:00'), 12, 0, 'Description|La projection de La dolce vita rend hommage au chef-d’œuvre de Federico Fellini, portrait éblouissant et mélancolique de la Rome mondaine. Entre scènes devenues mythiques, élégance en noir et blanc et regard ironique sur une société en quête de plaisirs, le film n’a rien perdu de sa puissance. La séance se prolonge par un échange avec le public, pour partager impressions et clés de lecture autour d’une œuvre phare du cinéma italien.§Lieu|Cinéma Le Rialto§Consigne PSH|Places réservées pour fauteuils roulants au premier rang. Sous-titres pour sourds et malentendants.§Liste d’attente|Vous êtes sur liste d’attente : si une place se libère, elle vous est attribuée automatiquement et vous recevez une notification.§Point de RDV|Hall du Cinéma Le Rialto, 20 minutes avant la séance.', UNHEX('CA000000000000000000000000000002')),
  -- Jour 3, matin
  (UNHEX('EE000000000000000000000000000005'), 'La Locandiera', TIMESTAMP(@d0 + INTERVAL 2 DAY, '07:30:00'), TIMESTAMP(@d0 + INTERVAL 2 DAY, '11:30:00'), 40, 0, 'Description|La Locandiera, comédie de Carlo Goldoni, met en scène Mirandolina, aubergiste espiègle qui séduit et déjoue les prétentions des gentilshommes de passage. Portée par une troupe italienne pleine d’énergie, la pièce mêle humour, finesse et vivacité, fidèle à l’esprit du théâtre de Goldoni. Un spectacle drôle et intemporel, qui célèbre l’intelligence et la liberté d’une héroïne en avance sur son temps.§Lieu|Théâtre Goldoni§Consigne PSH|Boucle magnétique pour les personnes malentendantes. Accès par l’entrée latérale.§Liste d’attente|Vous êtes sur liste d’attente : si une place se libère, elle vous est attribuée automatiquement et vous recevez une notification.§Point de RDV|Billetterie du Théâtre Goldoni.', UNHEX('CA000000000000000000000000000001')),
  -- Jour 3, après-midi
  (UNHEX('EE000000000000000000000000000006'), 'L''art du faux parfait', TIMESTAMP(@d0 + INTERVAL 2 DAY, '11:30:00'), TIMESTAMP(@d0 + INTERVAL 2 DAY, '17:30:00'), 25, 0, 'Description|L’art du faux parfait plonge le public dans l’univers fascinant des faussaires de génie, entre ateliers secrets, chefs-d’œuvre imités et enquêtes palpitantes. Au fil des scènes, la pièce interroge la frontière entre copie et création, talent et tromperie, admiration et imposture. Un spectacle intrigant et plein de rebondissements, qui invite à regarder les œuvres d’art d’un œil nouveau.§Lieu|Théâtre Goldoni§Consigne PSH|Boucle magnétique pour les personnes malentendantes. Accès par l’entrée latérale.§Liste d’attente|Vous êtes sur liste d’attente : si une place se libère, elle vous est attribuée automatiquement et vous recevez une notification.§Point de RDV|Billetterie du Théâtre Goldoni.', UNHEX('CA000000000000000000000000000001')),
  -- Jour 4, matin
  (UNHEX('EE000000000000000000000000000007'), 'Le Voleur de bicyclette', TIMESTAMP(@d0 + INTERVAL 3 DAY, '07:30:00'), TIMESTAMP(@d0 + INTERVAL 3 DAY, '11:30:00'), 10, 0, 'Description|Le Voleur de bicyclette, chef-d’œuvre de Vittorio De Sica, suit un père et son fils à travers Rome, à la recherche du vélo volé dont dépend leur survie. Présenté en version restaurée, ce film emblématique du néoréalisme italien saisit avec une justesse bouleversante la dignité et la fragilité des gens ordinaires de l’après-guerre. Une séance émouvante, pour découvrir ou redécouvrir un classique qui a marqué l’histoire du cinéma.§Lieu|Cinéma Le Rialto§Consigne PSH|Places réservées pour fauteuils roulants au premier rang. Sous-titres pour sourds et malentendants.§Liste d’attente|Vous êtes sur liste d’attente : si une place se libère, elle vous est attribuée automatiquement et vous recevez une notification.§Point de RDV|Hall du Cinéma Le Rialto, 20 minutes avant la séance.', UNHEX('CA000000000000000000000000000002')),
  -- Jour 4, après-midi
  (UNHEX('EE000000000000000000000000000008'), 'Tutta Vita Tour - Olly', TIMESTAMP(@d0 + INTERVAL 3 DAY, '11:30:00'), TIMESTAMP(@d0 + INTERVAL 3 DAY, '17:30:00'), 60, 0, 'Description|Le Tutta Vita Tour d’Olly célèbre l’énergie de la nouvelle scène musicale italienne à travers un concert vibrant, mêlant pop contemporaine, sonorités urbaines et mélodies entraînantes. Porté par la voix singulière et la présence scénique de Olly, le spectacle invite le public à partager un moment intense, entre émotions, rythmes festifs et refrains fédérateurs. Une expérience musicale authentique, reflet d’une génération qui fait vivre et évoluer la pop italienne.§Lieu|Scène Venezia§Consigne PSH|Plateforme surélevée réservée aux personnes à mobilité réduite. Bouchons d’oreilles offerts à l’entrée.§Liste d’attente|Vous êtes sur liste d’attente : si une place se libère, elle vous est attribuée automatiquement et vous recevez une notification.§Point de RDV|Entrée Nord de la Scène Venezia, ouverture des portes 30 minutes avant.', UNHEX('CA000000000000000000000000000004')),
  -- Jour 5, matin
  (UNHEX('EE000000000000000000000000000009'), 'Rome Ville ouverte', TIMESTAMP(@d0 + INTERVAL 4 DAY, '07:30:00'), TIMESTAMP(@d0 + INTERVAL 4 DAY, '11:30:00'), 12, 0, 'Description|Rome Ville ouverte, film de Roberto Rossellini, raconte la résistance des habitants de Rome face à l’occupation, à travers le destin d’un prêtre, d’une mère et d’un militant. Tourné dans les rues de la ville au lendemain de sa libération, il pose les bases du néoréalisme et frappe encore par sa force et son authenticité. Une projection marquante, pour découvrir une œuvre fondatrice qui a changé la façon de filmer le réel.§Lieu|Cinéma Le Rialto§Consigne PSH|Places réservées pour fauteuils roulants au premier rang. Sous-titres pour sourds et malentendants.§Liste d’attente|Vous êtes sur liste d’attente : si une place se libère, elle vous est attribuée automatiquement et vous recevez une notification.§Point de RDV|Hall du Cinéma Le Rialto, 20 minutes avant la séance.', UNHEX('CA000000000000000000000000000002')),
  -- Jour 5, après-midi
  (UNHEX('EE000000000000000000000000000010'), 'Nei letti degli altri Tour - Mahmood', TIMESTAMP(@d0 + INTERVAL 4 DAY, '11:30:00'), TIMESTAMP(@d0 + INTERVAL 4 DAY, '17:30:00'), 60, 0, 'Description|Le Nei letti degli altri Tour de Mahmood fait vibrer la scène au rythme de son dernier album, entre pop italienne, influences méditerranéennes et sonorités urbaines. Porté par une voix reconnaissable entre toutes et une écriture intime, le concert alterne moments d’émotion et énergie communicative. Un rendez-vous incontournable avec l’un des artistes les plus singuliers de la scène italienne actuelle.§Lieu|Scène Venezia§Consigne PSH|Plateforme surélevée réservée aux personnes à mobilité réduite. Bouchons d’oreilles offerts à l’entrée.§Liste d’attente|Vous êtes sur liste d’attente : si une place se libère, elle vous est attribuée automatiquement et vous recevez une notification.§Point de RDV|Entrée Nord de la Scène Venezia, ouverture des portes 30 minutes avant.', UNHEX('CA000000000000000000000000000004'));

-- 5. Réservations : l'ordre d'insertion donne l'id, donc l'ordre de la liste d'attente
INSERT INTO reservations (status, id_user, id_workshop) VALUES
  -- Éternel Tintoret
  ('validated', UNHEX('10000000000000000000000000000009'), UNHEX('EE000000000000000000000000000001')),
  ('validated', UNHEX('10000000000000000000000000000010'), UNHEX('EE000000000000000000000000000001')),
  ('validated', UNHEX('10000000000000000000000000000011'), UNHEX('EE000000000000000000000000000001')),
  ('validated', UNHEX('10000000000000000000000000000012'), UNHEX('EE000000000000000000000000000001')),
  ('validated', UNHEX('10000000000000000000000000000013'), UNHEX('EE000000000000000000000000000001')),
  ('validated', UNHEX('10000000000000000000000000000014'), UNHEX('EE000000000000000000000000000001')),
  ('validated', UNHEX('10000000000000000000000000000015'), UNHEX('EE000000000000000000000000000001')),
  ('validated', UNHEX('10000000000000000000000000000016'), UNHEX('EE000000000000000000000000000001')),
  ('validated', UNHEX('10000000000000000000000000000017'), UNHEX('EE000000000000000000000000000001')),
  ('validated', UNHEX('10000000000000000000000000000018'), UNHEX('EE000000000000000000000000000001')),
  ('pending', UNHEX('10000000000000000000000000000001'), UNHEX('EE000000000000000000000000000001')),
  ('pending', UNHEX('10000000000000000000000000000019'), UNHEX('EE000000000000000000000000000001')),
  -- L'atelier des enfants
  ('validated', UNHEX('10000000000000000000000000000016'), UNHEX('EE000000000000000000000000000002')),
  ('validated', UNHEX('10000000000000000000000000000017'), UNHEX('EE000000000000000000000000000002')),
  ('validated', UNHEX('10000000000000000000000000000018'), UNHEX('EE000000000000000000000000000002')),
  ('validated', UNHEX('10000000000000000000000000000019'), UNHEX('EE000000000000000000000000000002')),
  ('validated', UNHEX('10000000000000000000000000000020'), UNHEX('EE000000000000000000000000000002')),
  ('validated', UNHEX('10000000000000000000000000000002'), UNHEX('EE000000000000000000000000000002')),
  ('validated', UNHEX('10000000000000000000000000000003'), UNHEX('EE000000000000000000000000000002')),
  ('validated', UNHEX('10000000000000000000000000000001'), UNHEX('EE000000000000000000000000000002')),
  -- Ville Lumière ou Città Eterna
  ('validated', UNHEX('10000000000000000000000000000004'), UNHEX('EE000000000000000000000000000003')),
  ('validated', UNHEX('10000000000000000000000000000005'), UNHEX('EE000000000000000000000000000003')),
  ('validated', UNHEX('10000000000000000000000000000006'), UNHEX('EE000000000000000000000000000003')),
  ('validated', UNHEX('10000000000000000000000000000007'), UNHEX('EE000000000000000000000000000003')),
  ('validated', UNHEX('10000000000000000000000000000008'), UNHEX('EE000000000000000000000000000003')),
  ('validated', UNHEX('10000000000000000000000000000009'), UNHEX('EE000000000000000000000000000003')),
  ('validated', UNHEX('10000000000000000000000000000010'), UNHEX('EE000000000000000000000000000003')),
  ('validated', UNHEX('10000000000000000000000000000011'), UNHEX('EE000000000000000000000000000003')),
  ('validated', UNHEX('10000000000000000000000000000012'), UNHEX('EE000000000000000000000000000003')),
  ('validated', UNHEX('10000000000000000000000000000013'), UNHEX('EE000000000000000000000000000003')),
  ('validated', UNHEX('10000000000000000000000000000001'), UNHEX('EE000000000000000000000000000003')),
  ('cancelled', UNHEX('10000000000000000000000000000014'), UNHEX('EE000000000000000000000000000003')),
  ('cancelled', UNHEX('10000000000000000000000000000015'), UNHEX('EE000000000000000000000000000003')),
  -- La dolce vita
  ('validated', UNHEX('10000000000000000000000000000011'), UNHEX('EE000000000000000000000000000004')),
  ('validated', UNHEX('10000000000000000000000000000012'), UNHEX('EE000000000000000000000000000004')),
  ('validated', UNHEX('10000000000000000000000000000013'), UNHEX('EE000000000000000000000000000004')),
  ('validated', UNHEX('10000000000000000000000000000014'), UNHEX('EE000000000000000000000000000004')),
  ('validated', UNHEX('10000000000000000000000000000015'), UNHEX('EE000000000000000000000000000004')),
  ('validated', UNHEX('10000000000000000000000000000016'), UNHEX('EE000000000000000000000000000004')),
  ('validated', UNHEX('10000000000000000000000000000017'), UNHEX('EE000000000000000000000000000004')),
  ('validated', UNHEX('10000000000000000000000000000018'), UNHEX('EE000000000000000000000000000004')),
  ('validated', UNHEX('10000000000000000000000000000019'), UNHEX('EE000000000000000000000000000004')),
  ('validated', UNHEX('10000000000000000000000000000020'), UNHEX('EE000000000000000000000000000004')),
  ('validated', UNHEX('10000000000000000000000000000002'), UNHEX('EE000000000000000000000000000004')),
  ('validated', UNHEX('10000000000000000000000000000003'), UNHEX('EE000000000000000000000000000004')),
  ('pending', UNHEX('10000000000000000000000000000001'), UNHEX('EE000000000000000000000000000004')),
  -- La Locandiera
  ('validated', UNHEX('10000000000000000000000000000018'), UNHEX('EE000000000000000000000000000005')),
  ('validated', UNHEX('10000000000000000000000000000019'), UNHEX('EE000000000000000000000000000005')),
  ('validated', UNHEX('10000000000000000000000000000020'), UNHEX('EE000000000000000000000000000005')),
  ('validated', UNHEX('10000000000000000000000000000002'), UNHEX('EE000000000000000000000000000005')),
  ('validated', UNHEX('10000000000000000000000000000003'), UNHEX('EE000000000000000000000000000005')),
  ('validated', UNHEX('10000000000000000000000000000004'), UNHEX('EE000000000000000000000000000005')),
  ('validated', UNHEX('10000000000000000000000000000005'), UNHEX('EE000000000000000000000000000005')),
  ('validated', UNHEX('10000000000000000000000000000006'), UNHEX('EE000000000000000000000000000005')),
  ('validated', UNHEX('10000000000000000000000000000007'), UNHEX('EE000000000000000000000000000005')),
  ('validated', UNHEX('10000000000000000000000000000008'), UNHEX('EE000000000000000000000000000005')),
  ('validated', UNHEX('10000000000000000000000000000009'), UNHEX('EE000000000000000000000000000005')),
  ('validated', UNHEX('10000000000000000000000000000010'), UNHEX('EE000000000000000000000000000005')),
  ('validated', UNHEX('10000000000000000000000000000011'), UNHEX('EE000000000000000000000000000005')),
  ('validated', UNHEX('10000000000000000000000000000001'), UNHEX('EE000000000000000000000000000005')),
  -- L'art du faux parfait
  ('validated', UNHEX('10000000000000000000000000000006'), UNHEX('EE000000000000000000000000000006')),
  ('validated', UNHEX('10000000000000000000000000000007'), UNHEX('EE000000000000000000000000000006')),
  ('validated', UNHEX('10000000000000000000000000000008'), UNHEX('EE000000000000000000000000000006')),
  ('validated', UNHEX('10000000000000000000000000000009'), UNHEX('EE000000000000000000000000000006')),
  ('validated', UNHEX('10000000000000000000000000000010'), UNHEX('EE000000000000000000000000000006')),
  ('validated', UNHEX('10000000000000000000000000000011'), UNHEX('EE000000000000000000000000000006')),
  ('validated', UNHEX('10000000000000000000000000000012'), UNHEX('EE000000000000000000000000000006')),
  ('validated', UNHEX('10000000000000000000000000000013'), UNHEX('EE000000000000000000000000000006')),
  ('validated', UNHEX('10000000000000000000000000000001'), UNHEX('EE000000000000000000000000000006')),
  -- Le Voleur de bicyclette
  ('validated', UNHEX('10000000000000000000000000000013'), UNHEX('EE000000000000000000000000000007')),
  ('validated', UNHEX('10000000000000000000000000000014'), UNHEX('EE000000000000000000000000000007')),
  ('validated', UNHEX('10000000000000000000000000000015'), UNHEX('EE000000000000000000000000000007')),
  ('validated', UNHEX('10000000000000000000000000000016'), UNHEX('EE000000000000000000000000000007')),
  ('validated', UNHEX('10000000000000000000000000000017'), UNHEX('EE000000000000000000000000000007')),
  ('validated', UNHEX('10000000000000000000000000000018'), UNHEX('EE000000000000000000000000000007')),
  ('validated', UNHEX('10000000000000000000000000000019'), UNHEX('EE000000000000000000000000000007')),
  ('validated', UNHEX('10000000000000000000000000000020'), UNHEX('EE000000000000000000000000000007')),
  ('validated', UNHEX('10000000000000000000000000000002'), UNHEX('EE000000000000000000000000000007')),
  ('validated', UNHEX('10000000000000000000000000000003'), UNHEX('EE000000000000000000000000000007')),
  ('pending', UNHEX('10000000000000000000000000000001'), UNHEX('EE000000000000000000000000000007')),
  ('pending', UNHEX('10000000000000000000000000000004'), UNHEX('EE000000000000000000000000000007')),
  -- Tutta Vita Tour - Olly
  ('validated', UNHEX('10000000000000000000000000000020'), UNHEX('EE000000000000000000000000000008')),
  ('validated', UNHEX('10000000000000000000000000000002'), UNHEX('EE000000000000000000000000000008')),
  ('validated', UNHEX('10000000000000000000000000000003'), UNHEX('EE000000000000000000000000000008')),
  ('validated', UNHEX('10000000000000000000000000000004'), UNHEX('EE000000000000000000000000000008')),
  ('validated', UNHEX('10000000000000000000000000000005'), UNHEX('EE000000000000000000000000000008')),
  ('validated', UNHEX('10000000000000000000000000000006'), UNHEX('EE000000000000000000000000000008')),
  ('validated', UNHEX('10000000000000000000000000000007'), UNHEX('EE000000000000000000000000000008')),
  ('validated', UNHEX('10000000000000000000000000000008'), UNHEX('EE000000000000000000000000000008')),
  ('validated', UNHEX('10000000000000000000000000000009'), UNHEX('EE000000000000000000000000000008')),
  ('validated', UNHEX('10000000000000000000000000000010'), UNHEX('EE000000000000000000000000000008')),
  ('validated', UNHEX('10000000000000000000000000000011'), UNHEX('EE000000000000000000000000000008')),
  ('validated', UNHEX('10000000000000000000000000000012'), UNHEX('EE000000000000000000000000000008')),
  ('validated', UNHEX('10000000000000000000000000000013'), UNHEX('EE000000000000000000000000000008')),
  ('validated', UNHEX('10000000000000000000000000000014'), UNHEX('EE000000000000000000000000000008')),
  ('validated', UNHEX('10000000000000000000000000000015'), UNHEX('EE000000000000000000000000000008')),
  ('validated', UNHEX('10000000000000000000000000000001'), UNHEX('EE000000000000000000000000000008')),
  -- Rome Ville ouverte
  ('validated', UNHEX('10000000000000000000000000000008'), UNHEX('EE000000000000000000000000000009')),
  ('validated', UNHEX('10000000000000000000000000000009'), UNHEX('EE000000000000000000000000000009')),
  ('validated', UNHEX('10000000000000000000000000000010'), UNHEX('EE000000000000000000000000000009')),
  ('validated', UNHEX('10000000000000000000000000000011'), UNHEX('EE000000000000000000000000000009')),
  ('validated', UNHEX('10000000000000000000000000000012'), UNHEX('EE000000000000000000000000000009')),
  ('validated', UNHEX('10000000000000000000000000000013'), UNHEX('EE000000000000000000000000000009')),
  ('validated', UNHEX('10000000000000000000000000000014'), UNHEX('EE000000000000000000000000000009')),
  ('validated', UNHEX('10000000000000000000000000000015'), UNHEX('EE000000000000000000000000000009')),
  ('validated', UNHEX('10000000000000000000000000000016'), UNHEX('EE000000000000000000000000000009')),
  ('validated', UNHEX('10000000000000000000000000000017'), UNHEX('EE000000000000000000000000000009')),
  ('validated', UNHEX('10000000000000000000000000000018'), UNHEX('EE000000000000000000000000000009')),
  ('validated', UNHEX('10000000000000000000000000000019'), UNHEX('EE000000000000000000000000000009')),
  ('pending', UNHEX('10000000000000000000000000000001'), UNHEX('EE000000000000000000000000000009')),
  ('pending', UNHEX('10000000000000000000000000000020'), UNHEX('EE000000000000000000000000000009')),
  ('pending', UNHEX('10000000000000000000000000000002'), UNHEX('EE000000000000000000000000000009')),
  -- Nei letti degli altri Tour - Mahmood
  ('validated', UNHEX('10000000000000000000000000000015'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000016'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000017'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000018'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000019'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000020'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000002'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000003'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000004'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000005'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000006'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000007'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000008'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000009'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000010'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000011'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000012'), UNHEX('EE000000000000000000000000000010')),
  ('validated', UNHEX('10000000000000000000000000000001'), UNHEX('EE000000000000000000000000000010'));

-- 6. Places prises = nombre de réservations validées (comme le fait l'API)
UPDATE workshops w
SET w.subscriber_number = (
    SELECT COUNT(*) FROM reservations r
    WHERE r.id_workshop = w.id AND r.status = 'validated'
);
