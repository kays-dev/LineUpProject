// Le token reçu à la connexion est gardé dans le navigateur (localStorage)
function getToken() {
  return localStorage.getItem('token');
}

// Si on n'a pas de token, on renvoie vers la page de connexion
function verifierConnexion() {
  if (!getToken()) {
    window.location.href = 'Connexion.html';
  }
}

// Déconnexion : on efface le token et on retourne à la connexion
function logout() {
  localStorage.removeItem('token');
  window.location.href = 'Connexion.html';
}
