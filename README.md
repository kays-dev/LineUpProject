# LINEUP 🎪

Application iOS et back-office web pour le festival « Dolcevita Sur Seine » : les participants réservent leurs ateliers, les organisateurs gèrent le planning et les réservations.

## 📓 CONTEXTE

Projet réalisé en équipe de 4 dans le cadre de l'Advanced Apple Foundation Program — formation Concepteur Développeur d'Applications (RNCP37873) chez SIMPLON.CO, d'octobre à novembre 2026.

Le projet couvre toute la chaîne : conception de la base de données (MERISE / UML), API REST, application iOS pour les participants et back-office web pour le staff. L'équipe s'est organisée en Scrumban (user stories, dailies, tableau Notion).

## 🎯 FONCTIONNALITÉS

### Application iOS (participants)
- Inscription, connexion et restauration de session (token stocké dans le Keychain)
- Planning du festival et détail des ateliers
- Réservation d'ateliers, suivi de « Mes activités » et historique des réservations
- Profil utilisateur
- Application traduite en français et en anglais

### Back-office web (staff)
- Connexion et tableau de bord
- Gestion du planning, des ateliers et des catégories
- Gestion des réservations et des profils utilisateurs

### API REST
- Authentification JWT et gestion des utilisateurs
- Catégories, ateliers (filtres par catégorie, nom et période) et réservations (création, annulation, changement de statut)
- Routes réservées au staff grâce à un middleware de rôle
- Tests des contrôleurs avec VaporTesting

## 🛠 TECHNOLOGIES

| Partie | Technologies |
|---|---|
| Application iOS | Swift, SwiftUI, Observation, Keychain |
| API | Swift, Vapor, Fluent, MySQL / MariaDB, JWT |
| Back-office | HTML, CSS, JavaScript natif (fetch) |
| Conception | MERISE, UML (draw.io, dossier `Conception`) |

## 🚀 INSTALLATION

1. Cloner le projet

   ```bash
   git clone https://github.com/kays-dev/LineUpProject.git
   cd LineUpProject
   ```

2. Lancer l'API
   - Créer une base de données MySQL / MariaDB nommée `lineup`
   - Dans `LineUpAPI`, copier `.env.example` en `.env` et renseigner les accès à la base et la clé JWT
   - Lancer l'API depuis Xcode (`Package.swift`) ou avec `swift run`

3. Lancer l'application iOS
   - Ouvrir `LineUpApp/LineUpApp.xcodeproj` dans Xcode
   - Choisir un simulateur, puis Build & Run (⌘R)

4. Lancer le back-office
   - Renseigner l'adresse de l'API dans `LineUpBackOffice/js/config.js`
   - Ouvrir le dossier avec un serveur local (par exemple l'extension Live Server de VS Code)

## 👥 AUTEUR·ES

| Membre | GitHub | Contributions principales |
|---|---|---|
| Krystal | [@kays-dev](https://github.com/kays-dev) | Scrum Master · ressource Catégories et middleware de rôle (API) · architecture, couche réseau, authentification et écrans de réservation (iOS) |
| Hayat   | [@Hayat91800](https://github.com/Hayat91800) | Authentification JWT et utilisateurs (API) · back-office web |
| Imane   | [@imane-CDA](https://github.com/imane-CDA) | Ateliers (API) |
| Slimane | [@SlimaneZZZ] (https://github.com/SlimaneZZZ) | Réservations (API) |

## 📜 LICENSE

Ce projet a été développé dans le cadre pédagogique de l'Advanced Apple Foundation Program.