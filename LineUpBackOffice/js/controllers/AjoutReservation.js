const API_URL = API_BASE + '/backoffice/reservations';
const API_USERS_URL = API_BASE + '/backoffice/users';
const API_WORKSHOPS_URL = API_BASE + '/workshops';

verifierConnexion();

document.addEventListener('DOMContentLoaded', () => {
  fetchUsers();
  fetchWorkshops();
  document.getElementById('reservationForm').addEventListener('submit', ajouterReservation);
});

// Remplit la liste des festivaliers
async function fetchUsers() {
  try {
    const response = await fetch(`${API_USERS_URL}?role=festivalgoer`, { headers: getHeaders() });
    if (!response.ok) throw new Error(`Erreur HTTP : ${response.status}`);
    const users = await response.json();

    const select = document.getElementById('utilisateur');
    users.forEach(user => {
      select.innerHTML += `<option value="${user.id}">${escapeHtml(user.name)} (${escapeHtml(user.email)})</option>`;
    });
  } catch (error) {
    console.error('Impossible de récupérer les utilisateurs :', error);
  }
}

// Remplit la liste des ateliers
async function fetchWorkshops() {
  try {
    const response = await fetch(API_WORKSHOPS_URL, { headers: getHeaders() });
    if (!response.ok) throw new Error(`Erreur HTTP : ${response.status}`);
    const workshops = await response.json();

    const select = document.getElementById('atelier');
    workshops.forEach(workshop => {
      const texte = `${workshop.name} · ${formatDate(workshop.startTime)} ${formatHeure(workshop.startTime)}`;
      select.innerHTML += `<option value="${workshop.id}">${escapeHtml(texte)}</option>`;
    });
  } catch (error) {
    console.error('Impossible de récupérer les ateliers :', error);
  }
}

// Route Vapor : POST /backoffice/reservations (ReservationsController, réservée au staff).
// Corps attendu : { userID, workshopID }.
// Le serveur choisit seul le statut : validée s'il reste de la place, sinon en attente.
async function ajouterReservation(event) {
  event.preventDefault();

  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: getHeaders(true),
      body: JSON.stringify({
        userID: document.getElementById('utilisateur').value,
        workshopID: document.getElementById('atelier').value
      })
    });

    if (response.ok) {
      window.location.href = 'GestionReservation.html';
    } else if (response.status === 404 || response.status === 405) {
      afficherErreur('La route POST /backoffice/reservations est introuvable : vérifier que l\'API est à jour.');
    } else {
      afficherErreur(await getErrorMessage(response));
    }
  } catch (error) {
    console.error("Erreur réseau lors de l'ajout :", error);
    afficherErreur('Impossible de joindre le serveur.');
  }
}

function afficherErreur(texte) {
  const message = document.getElementById('message');
  message.textContent = texte;
  message.hidden = false;
}
