const API_URL = API_BASE + '/backoffice/reservations';
const API_WORKSHOPS_URL = API_BASE + '/workshops';

// L'API envoie les réservations par pages : on retient la page affichée
let pageCourante = 1;
const PAR_PAGE = 10;
let totalPages = 1;

verifierConnexion();

document.addEventListener('DOMContentLoaded', () => {
  fetchWorkshops();
  fetchReservations();

  // Quand on change un filtre, on revient à la page 1
  document.getElementById('searchInput').addEventListener('input', changerFiltre);
  document.getElementById('statusFilter').addEventListener('change', changerFiltre);
  document.getElementById('workshopFilter').addEventListener('change', changerFiltre);

  document.getElementById('btnPrecedent').addEventListener('click', () => {
    pageCourante--;
    fetchReservations();
  });
  document.getElementById('btnSuivant').addEventListener('click', () => {
    pageCourante++;
    fetchReservations();
  });
});

function changerFiltre() {
  pageCourante = 1;
  fetchReservations();
}

// Remplit la liste déroulante des ateliers
async function fetchWorkshops() {
  try {
    const response = await fetch(API_WORKSHOPS_URL, { headers: getHeaders() });
    if (!response.ok) throw new Error(`Erreur HTTP : ${response.status}`);
    const workshops = await response.json();

    const select = document.getElementById('workshopFilter');
    workshops.forEach(workshop => {
      select.innerHTML += `<option value="${workshop.id}">${escapeHtml(workshop.name)}</option>`;
    });
  } catch (error) {
    console.error('Impossible de récupérer les ateliers :', error);
  }
}

// Récupère une page de réservations avec les filtres choisis
async function fetchReservations() {
  try {
    // /backoffice/reservations?page=1&per=10&status=pending&workshop=...&search=...
    const params = new URLSearchParams({ page: pageCourante, per: PAR_PAGE });
    const search = document.getElementById('searchInput').value;
    const status = document.getElementById('statusFilter').value;
    const workshop = document.getElementById('workshopFilter').value;
    if (search) params.append('search', search);
    if (status) params.append('status', status);
    if (workshop) params.append('workshop', workshop);

    const response = await fetch(`${API_URL}?${params}`, { headers: getHeaders() });
    if (!response.ok) {
      throw new Error(`Erreur HTTP : ${response.status}`);
    }

    // La réponse contient "items" (la liste) et "metadata" (page, per, total)
    const data = await response.json();
    renderReservationsTable(data.items);

    // Mise à jour du nombre total et des boutons de pagination
    totalPages = Math.max(1, Math.ceil(data.metadata.total / data.metadata.per));
    document.getElementById('pageSubtitle').textContent = `${data.metadata.total} réservations`;
    document.getElementById('pageInfo').textContent = `Page ${pageCourante} / ${totalPages}`;
    document.getElementById('btnPrecedent').disabled = pageCourante <= 1;
    document.getElementById('btnSuivant').disabled = pageCourante >= totalPages;

  } catch (error) {
    console.error('Impossible de récupérer les réservations :', error);
    const tbody = document.getElementById('reservationTable');
    tbody.innerHTML = `<tr><td colspan="6" class="table-message erreur">Erreur de chargement des données du serveur.</td></tr>`;
  }
}

// Affiche une ligne par réservation
function renderReservationsTable(reservations) {
  const tbody = document.getElementById('reservationTable');
  tbody.innerHTML = '';

  if (reservations.length === 0) {
    tbody.innerHTML = `<tr><td colspan="6" class="table-message">Aucune réservation.</td></tr>`;
    return;
  }

  reservations.forEach(reservation => {
    const statut = getStatutReservation(reservation.status);

    const tr = document.createElement('tr');
    // Une réservation = une place, donc "Places" vaut toujours 1
    tr.innerHTML = `
      <td>${escapeHtml(reservation.userName)}</td>
      <td>${escapeHtml(reservation.workshopName)}</td>
      <td>${formatDate(reservation.startTime)} · ${formatHeure(reservation.startTime)}</td>
      <td>1</td>
      <td><span class="badge ${statut.classe}">${statut.texte}</span></td>
      <td>
        <div class="actions">
          <a href="ModificationReservation.html?id=${reservation.reservationID}" class="action-btn" title="Modifier">${ICONE_MODIFIER}</a>
          ${reservation.status === 'cancelled' ? '' : `<a href="#" class="action-btn delete" onclick="cancelReservation('${reservation.reservationID}'); return false;" title="Annuler la réservation">${ICONE_SUPPRIMER}</a>`}
        </div>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

// Annule une réservation (PATCH /backoffice/reservations/:id/cancel).
// Elle n'est PAS supprimée de la base : son statut passe à "cancelled", la place est remise
// à disposition par le serveur et la réservation reste visible dans la partie
// "Ateliers annulés" du profil du festivalier.
async function cancelReservation(id) {
  // Boîte de confirmation (même visuel que la maquette Figma)
  const confirme = await confirmer({
    titre: 'Annuler la réservation ?',
    texte: "La réservation passera en « Annulée » et restera visible dans le profil du festivalier. La place sera immédiatement remise à disposition.",
    boutonConfirmer: 'CONFIRMER',
    boutonAnnuler: 'RETOUR'
  });
  if (!confirme) return;

  try {
    const response = await fetch(`${API_URL}/${id}/cancel`, {
      method: 'PATCH',
      headers: getHeaders()
    });

    if (response.ok) {
      fetchReservations();
    } else {
      await afficherAlerte(await getErrorMessage(response));
    }
  } catch (error) {
    console.error("Erreur réseau lors de l'annulation :", error);
  }
}
