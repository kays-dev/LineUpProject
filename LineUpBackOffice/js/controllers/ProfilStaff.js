const API_URL = API_BASE + '/appios/users';

verifierConnexion();

document.addEventListener('DOMContentLoaded', () => {
  fetchMonProfil();
  document.getElementById('staffForm').addEventListener('submit', modifierMotDePasse);
});

// Récupère le profil de la personne connectée (le serveur lit son id dans le token)
async function fetchMonProfil() {
  try {
    const response = await fetch(`${API_URL}/me`, { headers: getHeaders() });
    if (!response.ok) throw new Error(`Erreur HTTP : ${response.status}`);
    const user = await response.json();

    document.getElementById('userName').textContent = user.name;
    document.getElementById('userEmail').textContent = user.email;
    document.getElementById('email').value = user.email;
    document.getElementById('avatar').textContent = user.name.charAt(0).toUpperCase();
  } catch (error) {
    console.error('Impossible de récupérer le profil :', error);
    afficherMessage('Erreur de chargement du profil.', true);
  }
}

// Change le mot de passe (PATCH /appios/users/me/password)
// Le serveur identifie la personne grâce au token : on envoie seulement l'ancien et le nouveau mot de passe
async function modifierMotDePasse(event) {
  event.preventDefault();

  const motDePasseActuel = document.getElementById('motDePasseActuel').value;
  const nouveauMotDePasse = document.getElementById('nouveauMotDePasse').value;

  // Vérifications simples avant d'appeler le serveur
  if (nouveauMotDePasse.length < 6) {
    afficherMessage('Le nouveau mot de passe doit contenir au moins 6 caractères.', true);
    return;
  }
  if (nouveauMotDePasse === motDePasseActuel) {
    afficherMessage("Le nouveau mot de passe doit être différent de l'ancien.", true);
    return;
  }

  // Les noms des champs doivent être exactement ceux attendus par Vapor (UpdatePasswordDTO)
  const donnees = {
    currentPassword: motDePasseActuel,
    newPassword: nouveauMotDePasse
  };

  try {
    const response = await fetch(`${API_URL}/me/password`, {
      method: 'PATCH',
      headers: getHeaders(true),
      body: JSON.stringify(donnees)
    });

    // Le serveur répond 204 (sans contenu) quand tout va bien
    if (response.ok) {
      document.getElementById('motDePasseActuel').value = '';
      document.getElementById('nouveauMotDePasse').value = '';
      afficherMessage('Mot de passe modifié.', false);
    } else {
      afficherMessage(await getErrorMessage(response), true);
    }
  } catch (error) {
    console.error('Erreur réseau lors du changement de mot de passe :', error);
    afficherMessage('Impossible de joindre le serveur.', true);
  }
}

// Affiche un message sous le formulaire (rouge si erreur, vert sinon)
function afficherMessage(texte, estErreur) {
  const message = document.getElementById('message');
  message.textContent = texte;
  message.style.color = estErreur ? '#de5266' : '#2f8f5b';
  message.hidden = false;
}
