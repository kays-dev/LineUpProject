// Stock l'adresse de l'API
const API_URL = API_BASE + '/workshops'; // workshops (lecture)
const API_BACKOFFICE_URL = API_BASE + '/backoffice/workshops'; // suppression (staff uniquement)
const API_CATEGORIES_URL = API_BASE + '/categories';
const API_RESERVATIONS_URL = API_BASE + '/backoffice/reservations';

// Nombre de personnes en liste d'attente, par atelier : { idAtelier: nombre }
let attenteParAtelier = {};

verifierConnexion();

// Attends que la page html soit complètement chargé avant d'exécuter les fonctions
document.addEventListener('DOMContentLoaded', async () => {
  fetchCategories();
  await fetchAttente();
  fetchActivities();

  // Quand on change un filtre, on recharge la liste avec le nouveau filtre
  document.getElementById('searchInput').addEventListener('input', fetchActivities);
  document.getElementById('categoryFilter').addEventListener('change', fetchActivities);
  document.getElementById('statusFilter').addEventListener('change', fetchActivities);
});

// Remplit la liste déroulante des catégories
async function fetchCategories() {
  try {
    const response = await fetch(API_CATEGORIES_URL, { headers: getHeaders() });
    if (!response.ok) throw new Error(`Erreur HTTP : ${response.status}`);
    const categories = await response.json();

    const select = document.getElementById('categoryFilter');
    categories.forEach(category => {
      select.innerHTML += `<option value="${escapeHtml(category.name)}">${escapeHtml(category.name)}</option>`;
    });
  } catch (error) {
    console.error('Impossible de récupérer les catégories :', error);
  }
}

// L'API ne donne pas la liste d'attente d'un atelier :
// on récupère les réservations "pending" et on les compte par atelier
async function fetchAttente() {
  try {
    const reservations = await fetchAllReservations({ status: 'pending' });
    attenteParAtelier = {};
    reservations.forEach(reservation => {
      attenteParAtelier[reservation.workshopID] = (attenteParAtelier[reservation.workshopID] || 0) + 1;
    });
  } catch (error) {
    console.error("Impossible de récupérer les listes d'attente :", error);
  }
}

// Async / await pour gérer les appels asynchrones à l'API
async function fetchActivities() {
  try {
    // On construit l'adresse avec les filtres choisis : /workshops?name=...&category=...&status=...
    const params = new URLSearchParams();
    const name = document.getElementById('searchInput').value;
    const category = document.getElementById('categoryFilter').value;
    const status = document.getElementById('statusFilter').value;
    if (name) params.append('name', name);
    if (category) params.append('category', category);
    if (status) params.append('status', status);

    // Envoi une requête GET au serveur Vapor pour récupérer les activités
    // (headers : le token prouve qu'on est connecté)
    const response = await fetch(`${API_URL}?${params}`, { headers: getHeaders() });
    // On vérifie le status de la réponse, si ce n'est pas ok on lance une erreur
    if (!response.ok) {
      throw new Error(`Erreur HTTP : ${response.status}`);
    }

    // Conversion de la réponse en JSON pour pouvoir l'utiliser dans le code
    const activities = await response.json();
    // On appelle la fonction d'affichage du tableau avec les activités récupérées
    renderActivitiesTable(activities);

  // Affichage d'un message d'erreur dans le tableau si la récupération des activités échoue
  } catch (error) {
    console.error('Impossible de récupérer les activités :', error);
    const tbody = document.getElementById('workshopTable');
    tbody.innerHTML = `<tr><td colspan="7" class="table-message erreur">Erreur de chargement des données du serveur.</td></tr>`;
  }
}

// Récupération de l'élément tableau HTML via Id que l'on vide d'éventuelles anciennes données
// et on le remplit avec les nouvelles données récupérées de l'API
function renderActivitiesTable(activities) {
  const tbody = document.getElementById('workshopTable');
  tbody.innerHTML = '';

  document.getElementById('pageSubtitle').textContent = `${activities.length} activités programmées`;

  // Si l'API renvoie un tableau vide, on affiche un message
  if (activities.length === 0) {
    tbody.innerHTML = `<tr><td colspan="7" class="table-message">Aucune activité programmée pour le moment.</td></tr>`;
    return;
  }

  // Boucle sur chaque élément du tableau reçu par Vapor
  activities.forEach(activity => {
    // On récupère la capacité max et le nombre d'inscrits
    const maxCap = activity.capacityMax || 0;
    const subNum = activity.subscriberNumber || 0;
    // On calcule le nombre d'inscrits en pourcentage (0% si 0)
    const percent = maxCap > 0 ? Math.round((subNum / maxCap) * 100) : 0;
    // On détermine la classe css et le texte du badge (fonction de common.js)
    const statut = getStatutAtelier(activity);

    // On crée une nouvelle ligne de tableau pour chaque activité
    const tr = document.createElement('tr');
    // et on y insère les données récupérées
    // Le bouton modifier redirige vers le formulaire de modification de l'activité
    tr.innerHTML = `
      <td>${escapeHtml(activity.name)}</td>
      <td>${formatHeure(activity.startTime)} – ${formatHeure(activity.endTime)}</td>
      <td>${escapeHtml(activity.categoryName)}</td>
      <td>${subNum} / ${maxCap} · ${percent} %</td>
      <td>${attenteParAtelier[activity.id] || 0}</td>
      <td><span class="badge ${statut.classe}">${statut.texte}</span></td>
      <td>
        <div class="actions">
          <a href="ModificationActivite.html?id=${activity.id}" class="action-btn" title="Modifier">${ICONE_MODIFIER}</a>
          <a href="#" class="action-btn delete" onclick="deleteActivity('${activity.id}'); return false;" title="Supprimer">${ICONE_SUPPRIMER}</a>
        </div>
      </td>
    `;

    tbody.appendChild(tr);
  });
}

// Fonction pour supprimer une activité via l'API
async function deleteActivity(id) {
  // Demande confirmation avant de supprimer l'activité
  // Boîte de confirmation (même visuel que la maquette Figma)
  const confirme = await confirmer({
    titre: "Supprimer l'activité ?",
    texte: "L'activité sera définitivement supprimée.",
    boutonConfirmer: 'SUPPRIMER'
  });
  if (!confirme) return;

  try {
    // Envoie la requête HTTP Delete
    const response = await fetch(`${API_BACKOFFICE_URL}/${id}`, {
      method: 'DELETE',
      headers: getHeaders()
    });

    // Si le serveur répond ok, on recharge la liste des activités mise à jour
    if (response.ok) {
      fetchActivities();
    } else {
      // Ex : le serveur refuse (409) si l'activité a déjà des réservations
      await afficherAlerte(await getErrorMessage(response));
    }
  } catch (error) {
    console.error('Erreur réseau lors de la suppression :', error);
  }
}
