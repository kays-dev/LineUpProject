const API_URL = API_BASE + '/workshops';

// Jour affiché (format 2026-07-03)
let jourChoisi = '';

verifierConnexion();

document.addEventListener('DOMContentLoaded', fetchJours);

// Récupère les jours du festival (GET /workshops/days) pour fabriquer un bouton par jour
// Vapor répond avec une liste de dates déjà triées, ex : ["2026-07-03", "2026-07-04"]
async function fetchJours() {
  try {
    const response = await fetch(`${API_URL}/days`, { headers: getHeaders() });
    if (!response.ok) throw new Error(`Erreur HTTP : ${response.status}`);
    const jours = await response.json();

    if (jours.length === 0) {
      document.getElementById('pageSubtitle').textContent = 'Aucun atelier programmé';
      return;
    }

    // On affiche par défaut aujourd'hui, sinon le premier jour du festival
    const aujourdhui = formatJour(new Date().toISOString());
    jourChoisi = jours.includes(aujourdhui) ? aujourdhui : jours[0];

    afficherBoutonsJours(jours);
    fetchPlanning();
  } catch (error) {
    console.error('Impossible de récupérer les jours :', error);
    document.getElementById('planningGrid').innerHTML = '<p class="table-message erreur">Erreur de chargement des données du serveur.</p>';
  }
}

// Crée un bouton par jour (ex : 03/07)
function afficherBoutonsJours(jours) {
  const picker = document.getElementById('datePicker');
  picker.innerHTML = '';

  jours.forEach(jour => {
    const bouton = document.createElement('button');
    bouton.className = 'date-pill' + (jour === jourChoisi ? ' active' : '');
    // "2026-07-03" -> "03/07"
    bouton.textContent = `${jour.slice(8, 10)}/${jour.slice(5, 7)}`;
    bouton.addEventListener('click', () => {
      jourChoisi = jour;
      afficherBoutonsJours(jours);
      fetchPlanning();
    });
    picker.appendChild(bouton);
  });
}

// Récupère les ateliers du jour choisi (filtre ?period=2026-07-03)
async function fetchPlanning() {
  try {
    const response = await fetch(`${API_URL}?period=${jourChoisi}`, { headers: getHeaders() });
    if (!response.ok) throw new Error(`Erreur HTTP : ${response.status}`);
    const workshops = await response.json();

    document.getElementById('pageSubtitle').textContent = `${workshops.length} ateliers · le ${jourChoisi.slice(8, 10)}/${jourChoisi.slice(5, 7)}`;
    renderPlanning(workshops);
  } catch (error) {
    console.error('Impossible de récupérer le planning :', error);
    document.getElementById('planningGrid').innerHTML = '<p class="table-message erreur">Erreur de chargement des données du serveur.</p>';
  }
}

// Une carte par atelier ; un clic ouvre la page pour déplacer l'atelier
function renderPlanning(workshops) {
  const grid = document.getElementById('planningGrid');
  grid.innerHTML = '';

  workshops.forEach(workshop => {
    const statut = getStatutAtelier(workshop);

    const carte = document.createElement('a');
    carte.className = 'workshop-card';
    carte.href = `ModificationPlanning.html?id=${workshop.id}`;
    carte.innerHTML = `
      <div class="workshop-hour">${formatHeure(workshop.startTime)}</div>
      <div class="workshop-info">
        <strong>${escapeHtml(workshop.name)}</strong>
        <span class="badge ${statut.classe}">${statut.texte}</span>
        <div>${workshop.remainingPlaces} places restantes / ${workshop.capacityMax}</div>
      </div>
    `;
    grid.appendChild(carte);
  });
}
