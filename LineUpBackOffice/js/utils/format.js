// Dates, heures, échappement du texte, lecture de ?id= dans l'adresse.

// Lit l'id dans l'adresse de la page (ex : ModificationActivite.html?id=123)
function getIdFromUrl() {
  return new URLSearchParams(window.location.search).get('id');
}

// Empêche un texte (ex : un nom saisi par un utilisateur) d'être interprété comme du html
function escapeHtml(texte) {
  return String(texte)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

// Le serveur envoie les dates au format "2026-07-03T14:15:00Z" : on les transforme
// Exemple : 14h15
function formatHeure(dateIso) {
  return new Date(dateIso)
    .toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit', timeZone: 'Europe/Paris' })
    .replace(':', 'h');
}

// Exemple : 03/07/2026
function formatDate(dateIso) {
  return new Date(dateIso).toLocaleDateString('fr-FR', { timeZone: 'Europe/Paris' });
}

// Exemple : 2026-07-03 (format attendu par un <input type="date"> et par le filtre ?periods=)
function formatJour(dateIso) {
  return new Date(dateIso).toLocaleDateString('sv-SE', { timeZone: 'Europe/Paris' });
}

// Exemple : 14:15 (format attendu par un <input type="time">)
function formatHeureInput(dateIso) {
  return new Date(dateIso).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit', timeZone: 'Europe/Paris' });
}

// Transforme une date et une heure saisies dans un formulaire en date pour le serveur
function versDateIso(jour, heure) {
  return new Date(`${jour}T${heure}`).toISOString();
}
