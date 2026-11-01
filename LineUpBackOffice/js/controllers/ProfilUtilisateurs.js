const API_URL = API_BASE + '/backoffice/users';

// Les réservations de tout le monde, récupérées une seule fois pour compter par utilisateur
let toutesReservations = [];

verifierConnexion();

document.addEventListener('DOMContentLoaded', async () => {
  try {
    toutesReservations = await fetchAllReservations();
  } catch (error) {
    console.error('Impossible de récupérer les réservations :', error);
  }
  fetchUsers();

  document.getElementById('searchInput').addEventListener('input', fetchUsers);
  document.getElementById('roleFilter').addEventListener('change', fetchUsers);
});

// Récupère les utilisateurs avec les filtres : /backoffice/users?name=...&role=...
async function fetchUsers() {
  try {
    const params = new URLSearchParams();
    const name = document.getElementById('searchInput').value;
    const role = document.getElementById('roleFilter').value;
    if (name) params.append('name', name);
    if (role) params.append('role', role);

    const response = await fetch(`${API_URL}?${params}`, { headers: getHeaders() });
    if (!response.ok) throw new Error(`Erreur HTTP : ${response.status}`);
    const users = await response.json();

    renderUsersTable(users);
  } catch (error) {
    console.error('Impossible de récupérer les utilisateurs :', error);
    const tbody = document.getElementById('userTable');
    tbody.innerHTML = `<tr><td colspan="6" class="table-message erreur">Erreur de chargement des données du serveur.</td></tr>`;
  }
}

function renderUsersTable(users) {
  const tbody = document.getElementById('userTable');
  tbody.innerHTML = '';

  document.getElementById('pageSubtitle').textContent = `${users.length} utilisateurs`;

  if (users.length === 0) {
    tbody.innerHTML = `<tr><td colspan="6" class="table-message">Aucun utilisateur.</td></tr>`;
    return;
  }

  users.forEach(user => {
    // On garde les réservations de cet utilisateur (l'API les identifie par e-mail)
    const siennes = toutesReservations.filter(reservation => reservation.userEmail === user.email);
    const listes = classerReservations(siennes);

    const tr = document.createElement('tr');
    tr.className = 'ligne-cliquable';
    // Un clic sur la ligne ouvre le profil
    tr.onclick = () => { window.location.href = `ProfilUtilisateur.html?id=${user.id}`; };
    tr.innerHTML = `
      <td>${escapeHtml(user.name)}</td>
      <td>${escapeHtml(user.email)}</td>
      <td>${listes.upcoming.length}</td>
      <td>${listes.history.length}</td>
      <td>${listes.cancelled.length}</td>
      <td>${user.role === 'staff' ? 'Staff' : 'Festivalier'}</td>
    `;
    tbody.appendChild(tr);
  });
}
