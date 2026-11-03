// Lecture : /workshops. Déplacement (modification) : /backoffice/workshops (staff uniquement)
const API_URL = API_BASE + '/workshops';
const API_BACKOFFICE_URL = API_BASE + '/backoffice/workshops';

// Id de l'atelier à déplacer (ModificationPlanning.html?id=...)
const workshopId = getIdFromUrl();

verifierConnexion();

document.addEventListener('DOMContentLoaded', () => {
  fetchWorkshop();
  document.getElementById('planningForm').addEventListener('submit', deplacerAtelier);
});

// Récupère l'atelier et affiche ses horaires actuels
async function fetchWorkshop() {
  try {
    const response = await fetch(`${API_URL}/${workshopId}`, { headers: getHeaders() });
    if (!response.ok) throw new Error(`Erreur HTTP : ${response.status}`);
    const workshop = await response.json();

    document.getElementById('pageSubtitle').textContent = `Planning · ${workshop.name}`;
    document.getElementById('atelier').value = workshop.name;
    document.getElementById('date').value = formatJour(workshop.startTime);
    document.getElementById('debut').value = formatHeureInput(workshop.startTime);
    document.getElementById('fin').value = formatHeureInput(workshop.endTime);
  } catch (error) {
    console.error("Impossible de récupérer l'atelier :", error);
    afficherErreur("Erreur de chargement de l'atelier.");
  }
}

// Envoie les nouveaux horaires (PATCH /backoffice/workshops/:id)
async function deplacerAtelier(event) {
  event.preventDefault();

  const jour = document.getElementById('date').value;
  const debut = document.getElementById('debut').value;
  const fin = document.getElementById('fin').value;

  if (fin <= debut) {
    afficherErreur("L'heure de fin doit être après l'heure de début.");
    return;
  }

  try {
    const response = await fetch(`${API_BACKOFFICE_URL}/${workshopId}`, {
      method: 'PATCH',
      headers: getHeaders(true),
      body: JSON.stringify({
        startTime: versDateIso(jour, debut),
        endTime: versDateIso(jour, fin)
      })
    });

    if (response.ok) {
      window.location.href = 'Planning.html';
    } else {
      afficherErreur(await getErrorMessage(response));
    }
  } catch (error) {
    console.error('Erreur réseau lors du déplacement :', error);
    afficherErreur('Impossible de joindre le serveur.');
  }
}

function afficherErreur(texte) {
  const message = document.getElementById('message');
  message.textContent = texte;
  message.hidden = false;
}
