// Lecture : /workshops (tout le monde). Modification : /backoffice/workshops (staff uniquement)
const API_URL = API_BASE + '/workshops';
const API_BACKOFFICE_URL = API_BASE + '/backoffice/workshops';
const API_CATEGORIES_URL = API_BASE + '/categories';

// Id de l'activité à modifier, lu dans l'adresse (ModificationActivite.html?id=...)
const activityId = getIdFromUrl();

let capacite = 20;

verifierConnexion();

document.addEventListener('DOMContentLoaded', async () => {
  // On remplit d'abord la liste des catégories, puis le formulaire
  await fetchCategories();
  fetchActivity();
  document.getElementById('activityForm').addEventListener('submit', modifierActivite);
});

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

// Récupère l'activité et remplit le formulaire avec ses valeurs actuelles
async function fetchActivity() {
  try {
    const response = await fetch(`${API_URL}/${activityId}`, { headers: getHeaders() });
    if (!response.ok) throw new Error(`Erreur HTTP : ${response.status}`);
    const activity = await response.json();

    document.getElementById('pageSubtitle').textContent = `Activités · ${activity.name}`;
    document.getElementById('nom').value = activity.name;
    document.getElementById('categorie').value = activity.categoryID;
    document.getElementById('date').value = formatJour(activity.startTime);
    document.getElementById('debut').value = formatHeureInput(activity.startTime);
    document.getElementById('fin').value = formatHeureInput(activity.endTime);
    document.getElementById('description').value = activity.workshopDescription;

    capacite = activity.capacityMax;
    document.getElementById('capacite').textContent = capacite;
  } catch (error) {
    console.error("Impossible de récupérer l'activité :", error);
    afficherErreur("Erreur de chargement de l'activité.");
  }
}

function changerCapacite(difference) {
  capacite = Math.max(0, capacite + difference);
  document.getElementById('capacite').textContent = capacite;
}

// Envoie les modifications à Vapor (PATCH /backoffice/workshops/:id)
async function modifierActivite(event) {
  event.preventDefault();

  const jour = document.getElementById('date').value;
  const debut = document.getElementById('debut').value;
  const fin = document.getElementById('fin').value;

  if (fin <= debut) {
    afficherErreur("L'heure de fin doit être après l'heure de début.");
    return;
  }

  // On n'envoie pas la catégorie : le serveur (UpdateWorkshopsDTO) ne la modifie pas
  const modifications = {
    name: document.getElementById('nom').value,
    startTime: versDateIso(jour, debut),
    endTime: versDateIso(jour, fin),
    capacityMax: capacite,
    workshopDescription: document.getElementById('description').value
  };

  try {
    const response = await fetch(`${API_BACKOFFICE_URL}/${activityId}`, {
      method: 'PATCH',
      headers: getHeaders(true),
      body: JSON.stringify(modifications)
    });

    if (response.ok) {
      window.location.href = 'GestionActivite.html';
    } else {
      afficherErreur(await getErrorMessage(response));
    }
  } catch (error) {
    console.error('Erreur réseau lors de la modification :', error);
    afficherErreur('Impossible de joindre le serveur.');
  }
}

function afficherErreur(texte) {
  const message = document.getElementById('message');
  message.textContent = texte;
  message.hidden = false;
}
