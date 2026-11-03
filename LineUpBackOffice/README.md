# LineUp — Back-office desktop (HTML + CSS + JavaScript natif)

Interface web du staff du festival : connexion, planning, activités (ateliers), catégories, réservations, profils.
HTML / CSS / JavaScript natif, sans framework. Le back-office est **indépendant de l'API** : il est servi à part
(il n'utilise pas le dossier `Public` de `LineUpAPI`) et appelle l'API Vapor avec `fetch`.

## Arborescence

```
LineUpBackOffice
├── index.html            redirige vers pages/Connexion.html
├── pages/                les vues (un fichier .html par écran)
├── css/
│   ├── base.css          menu, boutons, tableaux, badges, formulaires, boîtes de dialogue
│   └── Connexion.css, Dashboard.css, Planning.css, Profil.css   (une feuille par famille d'écrans)
└── js/
    ├── config.js         adresse de l'API (API_BASE) : le seul endroit à changer
    ├── services/
    │   ├── session.js    token, contrôle de connexion, déconnexion
    │   └── api.js        en-têtes des requêtes, messages d'erreur de Vapor, lecture paginée des réservations
    ├── utils/
    │   ├── format.js     dates, heures, échappement du texte, lecture de ?id=
    │   └── statuts.js    badges (disponible, complet, validée, en attente, annulée), classement des réservations
    ├── components/
    │   ├── icones.js     icônes des tableaux
    │   ├── modal.js      boîtes de dialogue (remplacent confirm() et alert())
    │   └── sidebar.js    nom et rôle de la personne connectée dans le menu
    └── controllers/      un script par page : appels à l'API et affichage
```

Chaque page charge, dans cet ordre : `config.js`, `session.js`, `api.js`, `format.js`, `statuts.js`,
`icones.js`, `modal.js`, `sidebar.js`, puis son contrôleur. Ce sont des scripts classiques (sans `import`) :
l'ordre de chargement est donc important.

## Écrans

| Écran | Page (`pages/`) | Contrôleur (`js/controllers/`) | CSS en plus de base.css |
|---|---|---|---|
| Connexion | `Connexion.html` | `Connexion.js` | `Connexion.css` |
| Création de compte staff | `CreationCompte.html` | `CreationCompte.js` | `Connexion.css` |
| Tableau de bord | `Dashboard.html` | `Dashboard.js` | `Dashboard.css` |
| Gestion des activités | `GestionActivite.html` | `GestionActivite.js` | — |
| Création / modification d'activité | `CreationActivite.html`, `ModificationActivite.html` | `CreationActivite.js`, `ModificationActivite.js` | — |
| Gestion des catégories | `GestionCategorie.html`, `FormulaireCategorie.html` | `GestionCategorie.js`, `FormulaireCategorie.js` | — |
| Planning et modification du planning | `Planning.html`, `ModificationPlanning.html` | `Planning.js`, `ModificationPlanning.js` | `Planning.css` |
| Gestion des réservations | `GestionReservation.html`, `AjoutReservation.html`, `ModificationReservation.html` | `GestionReservation.js`, `AjoutReservation.js`, `ModificationReservation.js` | — |
| Profils (liste, détail, staff) | `ProfilUtilisateurs.html`, `ProfilUtilisateur.html`, `ProfilStaff.html` | `ProfilUtilisateurs.js`, `ProfilUtilisateur.js`, `ProfilStaff.js` | `Profil.css` |

La « Connexion – erreur » de la maquette n'est pas une page à part : le message s'affiche sous les champs.
L'icône poubelle des réservations **annule** la réservation (`PATCH /:id/cancel`) : elle reste en base et apparaît
dans les réservations annulées du profil du festivalier.

## Lancer le back-office

1. Lancer l'API (`LineUpAPI`) sur `http://localhost:8080`.
2. Servir ce dossier sur un autre port, par exemple depuis `LineUpBackOffice` :
   ```
   python3 -m http.server 5500
   ```
   (ou l'extension « Live Server » de VS Code, port 5500).
3. Ouvrir `http://localhost:5500` — **pas** le fichier par double-clic : les appels à l'API seraient refusés.

### Réglage obligatoire côté API (CORS)

Le back-office et l'API sont sur deux origines différentes. Dans `LineUpAPI/Sources/LineUpAPI/configure.swift`,
le CORS doit autoriser l'origine du back-office, et les méthodes `PATCH` et `PUT` :

```swift
allowedOrigin : .custom("http://localhost:5500"),
allowedMethods: [.GET, .POST, .PUT, .PATCH, .DELETE, .OPTIONS],
```

Sans cela le navigateur bloque les requêtes (« Impossible de joindre le serveur » à la connexion).
Si l'adresse de l'API change, modifier uniquement `API_BASE` dans `js/config.js`.

## Routes de l'API utilisées

| Ce que fait la page | Route |
|---|---|
| Connexion (réponse = token en texte) | `POST /auth/login` |
| Personne connectée ; changement de mot de passe | `GET /appios/users/me` ; `PATCH /appios/users/me/password` (`{currentPassword, newPassword}`, réponse 204) |
| Activités (lecture) | `GET /workshops?name&category&status&period`, `GET /workshops/:id`, `GET /workshops/days` |
| Activités (écriture, staff) | `POST /backoffice/workshops`, `PATCH /backoffice/workshops/:id`, `DELETE /backoffice/workshops/:id` |
| Catégories | `GET /categories` ; `POST`, `PUT /:id`, `DELETE /:id` sur `/backoffice/categories` |
| Réservations (staff) | `GET /backoffice/reservations?page&per&status&workshop&search`, `GET /:id`, `POST` (`{userID, workshopID}`), `PATCH /:id/status`, `PATCH /:id/cancel` |
| Utilisateurs (staff) | `GET /backoffice/users?name&role`, `GET /backoffice/users/:id`, `POST /backoffice/users` (crée un staff) |

Le token est gardé dans `localStorage` et envoyé dans l'en-tête `Authorization: Bearer …` (`getHeaders()` dans `services/api.js`).

## Points connus côté API

- **Catégorie d'une activité** : `UpdateWorkshopsDTO` accepte `categoryID` mais `update()` dans `WorkshopsController`
  ne l'applique pas. Le champ « Type d'activité » est donc désactivé sur `ModificationActivite.html`.
- **Liste d'attente** : l'API ne la donne pas par atelier. La colonne « Attente » compte les réservations `pending`
  de chaque atelier (`GestionActivite.js`).
- **Réservations d'un utilisateur** : l'API ne filtre pas par id. Les profils retrouvent les réservations par e-mail
  (`?search=` puis tri exact sur l'e-mail).
