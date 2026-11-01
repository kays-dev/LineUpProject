const API_URL = API_BASE + '/backoffice/reservations';
const API_WORKSHOPS_URL = API_BASE + '/workshops';

// Id de la réservation (ModificationReservation.html?id=...)
const reservationId = getIdFromUrl();

verifierConnexion();

document.addEventListener('DOMContentLoaded', () => {
  fetchReservation();
  document.getElementById('reservationForm').addEventListener('submit', modifierStatut);
});

// Récupère la réservation. Seul le statut peut être modifié : le reste est en lecture seule.
async function fetchReservation() {
  try {
    const response = await fetch(`${API_URL}/${reservationId}`, { headers: getHeaders() });
    if (!response.ok) throw new Error(`Erreur HTTP : ${response.status}`);
    const reservation = await response.json();

    document.getElementById('pageSubtitle').textContent = `Réservations · AR-${reservation.reservationID}`;
    document.getElementById('titreReservation').textContent = `RÉSERVATION AR-${reservation.reservationID}`;
    document.getElementById('numero').value = `AR-${reservation.reservationID}`;
    document.getElementById('utilisateur').value = reservation.userName;
    document.getElementById('atelier').value = `${reservation.workshopName} · ${formatDate(reservation.startTime)} ${formatHeure(reservation.startTime)}`;

    // On coche le statut actuel (validated / pending / cancelled)
    document.querySelector(`input[name="statut"][value="${reservation.status}"]`).checked = true;

    fetchPlacesRestantes(reservation.workshopID);
  } catch (error) {
    console.error('Impossible de récupérer la réservation :', error);
    afficherErreur('Erreur de chargement de la réservation.');
  }
}

// Affiche les places restantes de l'atelier
async function fetchPlacesRestantes(workshopID) {
  const response = await fetch(`${API_WORKSHOPS_URL}/${workshopID}`, { headers: getHeaders() });
  if (!response.ok) return;
  const workshop = await response.json();
  document.getElementById('placesRestantes').textContent =
    `Places restantes sur cet atelier : ${workshop.remainingPlaces} / ${workshop.capacityMax}`;
}

// Envoie le nouveau statut (PATCH /backoffice/reservations/:id/status)
// Le serveur vérifie les places et la liste d'attente, et renvoie une erreur si ce n'est pas possible
async function modifierStatut(event) {
  event.preventDefault();

  const statut = document.querySelector('input[name="statut"]:checked').value;

  try {
    const response = await fetch(`${API_URL}/${reservationId}/status`, {
      method: 'PATCH',
      headers: getHeaders(true),
      body: JSON.stringify({ status: statut })
    });

    if (response.ok) {
      window.location.href = 'GestionReservation.html';
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
