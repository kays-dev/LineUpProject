// Seul un membre du staff déjà connecté peut créer un compte staff
const API_URL = API_BASE + '/backoffice/users';

verifierConnexion();

document.addEventListener('DOMContentLoaded', () => {
  document.getElementById('signupForm').addEventListener('submit', creerCompte);
});

async function creerCompte(event) {
  event.preventDefault();

  const nom = document.getElementById('nom').value;
  const prenom = document.getElementById('prenom').value;
  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;
  const password2 = document.getElementById('password2').value;

  // Vérifications simples avant d'appeler le serveur
  if (password.length < 6) {
    afficherErreur('Le mot de passe doit contenir au moins 6 caractères.');
    return;
  }
  if (password !== password2) {
    afficherErreur('Les deux mots de passe sont différents.');
    return;
  }

  try {
    // Dans la base de données, le nom et le prénom sont réunis dans un seul champ "name"
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: getHeaders(true),
      body: JSON.stringify({ name: `${prenom} ${nom}`, email: email, password: password })
    });

    if (response.ok) {
      window.location.href = 'ProfilUtilisateurs.html';
    } else {
      // Ex : 409 si l'e-mail existe déjà
      afficherErreur(await getErrorMessage(response));
    }
  } catch (error) {
    console.error('Erreur lors de la création du compte :', error);
    afficherErreur('Impossible de joindre le serveur.');
  }
}

function afficherErreur(texte) {
  const message = document.getElementById('message');
  message.textContent = texte;
  message.hidden = false;
}
