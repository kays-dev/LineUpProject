// En-têtes envoyés à chaque requête : le token prouve qu'on est connecté.
// Si on envoie du JSON (POST / PATCH), on passe true pour ajouter Content-Type.
function getHeaders(avecJson = false) {
  const headers = { 'Authorization': 'Bearer ' + getToken() };
  if (avecJson) {
    headers['Content-Type'] = 'application/json';
  }
  return headers;
}

// Récupère le message d'erreur envoyé par Vapor
async function getErrorMessage(response) {
  try {
    const data = await response.json();
    return data.reason || `Erreur HTTP : ${response.status}`;
  } catch (error) {
    return `Erreur HTTP : ${response.status}`;
  }
}

// L'API envoie l'atelier dans un objet "workshop". On remet ses champs à plat
// (workshopID, workshopName, startTime, endTime) pour que les pages les lisent comme avant.
function aplatirReservation(reservation) {
  const atelier = reservation.workshop || {};
  return {
    ...reservation,
    workshopID: reservation.workshopID ?? atelier.id,
    workshopName: reservation.workshopName ?? atelier.name,
    startTime: reservation.startTime ?? atelier.startTime,
    endTime: reservation.endTime ?? atelier.endTime
  };
}

// Récupère TOUTES les réservations (l'API les envoie par pages de 10 maximum)
async function fetchAllReservations(filtres = {}) {
  const toutes = [];
  let page = 1;

  while (true) {
    const params = new URLSearchParams({ ...filtres, page: page, per: 100 });
    const response = await fetch(`${API_BASE}/backoffice/reservations?${params}`, { headers: getHeaders() });
    if (!response.ok) {
      throw new Error(`Erreur HTTP : ${response.status}`);
    }
    const data = await response.json();
    toutes.push(...data.items.map(aplatirReservation));

    // On s'arrête quand on a tout reçu
    if (data.items.length === 0 || toutes.length >= data.metadata.total) {
      break;
    }
    page++;
  }
  return toutes;
}
