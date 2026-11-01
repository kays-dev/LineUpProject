// Adresse de l'API pour se connecter
const API_URL = API_BASE + '/auth/login';

// Attend que la page html soit complètement chargée avant d'écouter le formulaire
document.addEventListener('DOMContentLoaded', () => {
  document.getElementById('loginForm').addEventListener('submit', login);
});

// Envoie l'e-mail et le mot de passe à Vapor, qui répond avec un token
async function login(event) {
  // Empêche le formulaire de recharger la page
  event.preventDefault();

  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;

  try {
    // Requête POST avec l'e-mail et le mot de passe en JSON
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: email, password: password })
    });

    // Si le serveur refuse (401), on affiche l'erreur sous les champs
    if (!response.ok) {
      afficherErreur('Identifiant ou mot de passe incorrect.');
      return;
    }

    // Vapor renvoie le token en texte simple (pas en JSON)
    const token = await response.text();
    localStorage.setItem('token', token);

    // On vérifie que la personne est bien du staff : le backoffice leur est réservé
    const meResponse = await fetch(`${API_BASE}/appios/users/me`, { headers: getHeaders() });
    const user = await meResponse.json();
    if (user.role !== 'staff') {
      localStorage.removeItem('token');
      afficherErreur("Accès réservé à l'équipe du festival.");
      return;
    }

    // Tout est bon : direction le tableau de bord
    window.location.href = 'Dashboard.html';

  } catch (error) {
    console.error('Erreur de connexion :', error);
    afficherErreur('Impossible de joindre le serveur.');
  }
}

// Affiche un message d'erreur et met les champs en rouge
function afficherErreur(texte) {
  const message = document.getElementById('message');
  message.textContent = texte;
  message.hidden = false;
  document.getElementById('email').classList.add('champ-erreur');
  document.getElementById('password').classList.add('champ-erreur');
}
