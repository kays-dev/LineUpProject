const API_URL = API_BASE + '/workshops';
const API_RESERVATIONS_URL = API_BASE + '/backoffice/reservations';

verifierConnexion();

document.addEventListener('DOMContentLoaded', fetchDashboard);

async function fetchDashboard() {
  try {
    // 1. Tous les ateliers (déjà triés par heure par Vapor)
    const response = await fetch(API_URL, { headers: getHeaders() });
    if (!response.ok) throw new Error(`Erreur HTTP : ${response.status}`);
    const workshops = await response.json();

    // 2. On choisit le jour à afficher et on garde les ateliers de ce jour
    const jour = choisirJour(workshops);
    const ateliersDuJour = workshops.filter(workshop => formatJour(workshop.startTime) === jour);

    // 3. Les chiffres : nombre d'ateliers et places restantes du jour
    document.getElementById('jourAffiche').textContent = jour ? formatDate(jour + 'T12:00:00Z') : '';
    document.getElementById('statActivites').textContent = ateliersDuJour.length;
    const placesRestantes = ateliersDuJour.reduce((total, workshop) => total + workshop.remainingPlaces, 0);
    document.getElementById('statPlaces').textContent = placesRestantes;

    // 4. Les tableaux et les chiffres de réservations
    renderAgenda(ateliersDuJour);
    renderProchains(workshops);
    fetchChiffresReservations();

  } catch (error) {
    console.error('Impossible de récupérer le tableau de bord :', error);
    document.getElementById('agendaTable').innerHTML = `<tr><td colspan="5" class="table-message erreur">Erreur de chargement des données du serveur.</td></tr>`;
  }
}

// Jour à afficher : aujourd'hui s'il y a des ateliers, sinon le prochain jour de festival
// (ou le dernier si le festival est terminé)
function choisirJour(workshops) {
  const jours = [...new Set(workshops.map(workshop => formatJour(workshop.startTime)))].sort();
  if (jours.length === 0) return '';

  const aujourdhui = formatJour(new Date().toISOString());
  if (jours.includes(aujourdhui)) return aujourdhui;

  const prochain = jours.find(jour => jour > aujourdhui);
  return prochain || jours[jours.length - 1];
}

// Le nombre total de réservations et la liste d'attente :
// on demande 1 seule réservation par page, car on veut seulement le total (metadata.total)
async function fetchChiffresReservations() {
  try {
    const toutes = await fetch(`${API_RESERVATIONS_URL}?per=1`, { headers: getHeaders() });
    const enAttente = await fetch(`${API_RESERVATIONS_URL}?per=1&status=pending`, { headers: getHeaders() });

    document.getElementById('statReservations').textContent = (await toutes.json()).metadata.total;
    document.getElementById('statAttente').textContent = (await enAttente.json()).metadata.total;
  } catch (error) {
    console.error('Impossible de récupérer les réservations :', error);
  }
}

// Tableau « Activités du jour »
function renderAgenda(workshops) {
  const tbody = document.getElementById('agendaTable');
  tbody.innerHTML = '';

  if (workshops.length === 0) {
    tbody.innerHTML = `<tr><td colspan="5" class="table-message">Aucune activité programmée.</td></tr>`;
    return;
  }

  workshops.forEach(workshop => {
    const statut = getStatutAtelier(workshop);
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${formatHeure(workshop.startTime)}</td>
      <td>${escapeHtml(workshop.name)}</td>
      <td>${escapeHtml(workshop.categoryName)}</td>
      <td>${workshop.subscriberNumber} / ${workshop.capacityMax}</td>
      <td><span class="badge ${statut.classe}">${statut.texte}</span></td>
    `;
    tbody.appendChild(tr);
  });
}

// « Planning immédiat » : les 3 prochains ateliers à partir de maintenant
function renderProchains(workshops) {
  const conteneur = document.getElementById('prochainsAteliers');
  const maintenant = new Date();
  const prochains = workshops
    .filter(workshop => new Date(workshop.startTime) > maintenant)
    .slice(0, 3);

  if (prochains.length === 0) {
    conteneur.innerHTML = '<p class="note">Aucun atelier à venir.</p>';
    return;
  }

  conteneur.innerHTML = '';
  prochains.forEach(workshop => {
    const statut = getStatutAtelier(workshop);
    conteneur.innerHTML += `
      <div class="mini-card">
        <strong>${formatHeure(workshop.startTime)} · ${escapeHtml(workshop.name)}</strong>
        ${workshop.remainingPlaces} places restantes / ${workshop.capacityMax}<br>
        <span class="badge ${statut.classe}">${statut.texte}</span>
      </div>
    `;
  });
}
