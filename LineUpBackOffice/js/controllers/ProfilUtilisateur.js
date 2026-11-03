const API_URL = API_BASE + '/backoffice/users';

// Id de l'utilisateur (ProfilUtilisateur.html?id=...)
const userId = getIdFromUrl();

verifierConnexion();

document.addEventListener('DOMContentLoaded', fetchUser);

// Récupère l'utilisateur et affiche son identité
async function fetchUser() {
  try {
    const response = await fetch(`${API_URL}/${userId}`, { headers: getHeaders() });
    if (!response.ok) throw new Error(`Erreur HTTP : ${response.status}`);
    const user = await response.json();

    document.getElementById('pageSubtitle').textContent = `Utilisateurs › ${user.name}`;
    document.getElementById('userName').textContent = user.name;
    document.getElementById('userEmail').textContent = user.email;
    document.getElementById('avatar').textContent = user.name.charAt(0).toUpperCase();

    fetchUserReservations(user.email);
  } catch (error) {
    console.error("Impossible de récupérer l'utilisateur :", error);
    document.getElementById('userName').textContent = 'Utilisateur introuvable';
  }
}

// Récupère les réservations de l'utilisateur et remplit les 3 tableaux.
// Rien n'est supprimé : une réservation annulée reste dans la liste « annulés ».
async function fetchUserReservations(email) {
  try {
    // « search » cherche dans le nom ET l'e-mail : on garde ensuite uniquement l'e-mail exact
    const trouvees = await fetchAllReservations({ search: email });
    const siennes = trouvees.filter(reservation => reservation.userEmail === email);

    const listes = classerReservations(siennes);

    renderReservations('upcomingTable', 'upcomingCount', listes.upcoming);
    renderReservations('historyTable', 'historyCount', listes.history);
    renderReservations('cancelledTable', 'cancelledCount', listes.cancelled);
  } catch (error) {
    console.error('Impossible de récupérer les réservations :', error);
  }
}

// Remplit un tableau avec une liste de réservations
function renderReservations(tbodyId, countId, reservations) {
  const tbody = document.getElementById(tbodyId);
  tbody.innerHTML = '';
  document.getElementById(countId).textContent = reservations.length;

  if (reservations.length === 0) {
    tbody.innerHTML = `<tr><td colspan="5" class="table-message">Aucune réservation.</td></tr>`;
    return;
  }

  reservations.forEach(reservation => {
    const statut = getStatutReservation(reservation.status);
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${escapeHtml(reservation.workshopName)}</td>
      <td>${formatDate(reservation.startTime)}</td>
      <td>${formatHeure(reservation.startTime)} – ${formatHeure(reservation.endTime)}</td>
      <td>1</td>
      <td><span class="badge ${statut.classe}">${statut.texte}</span></td>
    `;
    tbody.appendChild(tr);
  });
}
