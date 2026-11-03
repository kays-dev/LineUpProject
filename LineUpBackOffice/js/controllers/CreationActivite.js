// La création est réservée au staff : elle passe par /backoffice/workshops
const API_URL = API_BASE + '/backoffice/workshops';
const API_CATEGORIES_URL = API_BASE + '/categories';
const API_BACKOFFICE_CATEGORIES_URL = API_BASE + '/backoffice/categories'; // création d'une catégorie (staff)

// Jauge de départ (le compteur +/-)
let capacite = 20;

verifierConnexion();

document.addEventListener('DOMContentLoaded', () => {
  fetchCategories();
  document.getElementById('activityForm').addEventListener('submit', creerActivite);
});

// Remplit la liste déroulante "Type d'activité" avec les catégories de l'API
async function fetchCategories() {
  try {
    const response = await fetch(API_CATEGORIES_URL, { headers: getHeaders() });
    if (!response.ok) throw new Error(`Erreur HTTP : ${response.status}`);
    const categories = await response.json();

    const select = document.getElementById('categorie');
    categories.forEach(category => {
      select.innerHTML += `<option value="${category.id}">${escapeHtml(category.name)}</option>`;
    });
  } catch (error) {
    console.error('Impossible de récupérer les catégories :', error);
  }
}

// Plie / déplie le champ "Nouvelle catégorie" (lien sous la liste des types)
function basculerNouvelleCategorie() {
  const bloc = document.getElementById('blocNouvelleCategorie');
  const bouton = document.getElementById('boutonCategorie');
  bloc.hidden = !bloc.hidden;

  if (bloc.hidden) {
    bouton.textContent = '+ AJOUTER UNE CATÉGORIE';
    document.getElementById('nouvelleCategorie').value = '';
    document.getElementById('categorie').required = true;
  } else {
    bouton.textContent = '− MASQUER LA NOUVELLE CATÉGORIE';
    // Tant que la nouvelle catégorie est utilisée, la liste n'est plus nécessaire
    document.getElementById('categorie').required = false;
    document.getElementById('nouvelleCategorie').focus();
  }
}

// Crée la catégorie saisie (POST /backoffice/categories) et renvoie son id
async function creerCategorie(nom) {
  const response = await fetch(API_BACKOFFICE_CATEGORIES_URL, {
    method: 'POST',
    headers: getHeaders(true),
    body: JSON.stringify({ name: nom })
  });
  if (!response.ok) {
    throw new Error(await getErrorMessage(response));
  }
  const categorie = await response.json();
  return categorie.id;
}

// Boutons + et - de la jauge (on ne descend pas sous 0)
function changerCapacite(difference) {
  capacite = Math.max(0, capacite + difference);
  document.getElementById('capacite').textContent = capacite;
}

// Envoie la nouvelle activité à Vapor (POST /backoffice/workshops)
async function creerActivite(event) {
  event.preventDefault();

  const jour = document.getElementById('date').value;
  const debut = document.getElementById('debut').value;
  const fin = document.getElementById('fin').value;

  if (fin <= debut) {
    afficherErreur("L'heure de fin doit être après l'heure de début.");
    return;
  }

  // Si une nouvelle catégorie est saisie, on la crée d'abord pour récupérer son id
  let categoryID = document.getElementById('categorie').value;
  const nouvelle = document.getElementById('nouvelleCategorie').value.trim();
  if (!document.getElementById('blocNouvelleCategorie').hidden && nouvelle) {
    try {
      categoryID = await creerCategorie(nouvelle);
    } catch (error) {
      afficherErreur(error.message);
      return;
    }
  }
  if (!categoryID) {
    afficherErreur('Choisissez un type ou créez une nouvelle catégorie.');
    return;
  }

  // Les noms des champs doivent être exactement ceux attendus par Vapor (CreateWorkshopsDTO)
  const nouvelleActivite = {
    name: document.getElementById('nom').value,
    startTime: versDateIso(jour, debut),
    endTime: versDateIso(jour, fin),
    capacityMax: capacite,
    subscriberNumber: 0,
    workshopDescription: document.getElementById('description').value,
    categoryID: categoryID
  };

  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: getHeaders(true),
      body: JSON.stringify(nouvelleActivite)
    });

    if (response.ok) {
      window.location.href = 'GestionActivite.html';
    } else {
      afficherErreur(await getErrorMessage(response));
    }
  } catch (error) {
    console.error("Erreur réseau lors de la création :", error);
    afficherErreur('Impossible de joindre le serveur.');
  }
}

function afficherErreur(texte) {
  const message = document.getElementById('message');
  message.textContent = texte;
  message.hidden = false;
}
