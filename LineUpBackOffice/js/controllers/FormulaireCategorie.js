// Lecture des catégories (tout le monde) / écriture (staff uniquement)
const API_URL = API_BASE + '/categories';
const API_BACKOFFICE_URL = API_BASE + '/backoffice/categories';

// 'ajouter' (POST) ou 'modifier' (PUT)
let mode = 'ajouter';
// Liste des catégories existantes et celle qui est sélectionnée en mode modifier
let categories = [];
let categorieChoisie = null;

verifierConnexion();

document.addEventListener('DOMContentLoaded', async () => {
  await fetchCategories();
  document.getElementById('categoryForm').addEventListener('submit', enregistrer);

  // Si on arrive depuis le crayon du tableau (?id=...), on ouvre directement en mode modifier
  const id = getIdFromUrl();
  const categorie = categories.find(c => c.id === id);
  if (categorie) {
    categorieChoisie = categorie;
    choisirMode('modifier');
  } else {
    choisirMode('ajouter');
  }
});

// Récupère les catégories pour les pastilles
async function fetchCategories() {
  try {
    const response = await fetch(API_URL, { headers: getHeaders() });
    if (!response.ok) throw new Error(`Erreur HTTP : ${response.status}`);
    categories = await response.json();
  } catch (error) {
    console.error('Impossible de récupérer les catégories :', error);
    afficherErreur('Impossible de charger les catégories.');
  }
}

// Bascule entre Ajouter et Modifier
function choisirMode(nouveauMode) {
  mode = nouveauMode;
  masquerErreur();

  document.getElementById('boutonAjouter').classList.toggle('active', mode === 'ajouter');
  document.getElementById('boutonModifier').classList.toggle('active', mode === 'modifier');
  document.getElementById('blocExistantes').hidden = (mode === 'ajouter');

  if (mode === 'ajouter') {
    document.getElementById('nom').value = '';
  } else {
    // Par défaut on propose la première catégorie de la liste
    if (!categorieChoisie) categorieChoisie = categories[0] || null;
    afficherPastilles();
    document.getElementById('nom').value = categorieChoisie ? categorieChoisie.name : '';
  }
}

// Affiche une pastille par catégorie, celle choisie est en rouge
function afficherPastilles() {
  const liste = document.getElementById('listeCategories');
  liste.innerHTML = '';

  categories.forEach(category => {
    const bouton = document.createElement('button');
    bouton.type = 'button';
    bouton.textContent = category.name;
    if (categorieChoisie && category.id === categorieChoisie.id) {
      bouton.classList.add('active');
    }
    // Un clic sur la pastille remplit le champ avec le nom de la catégorie
    bouton.addEventListener('click', () => {
      categorieChoisie = category;
      document.getElementById('nom').value = category.name;
      afficherPastilles();
    });
    liste.appendChild(bouton);
  });
}

// Envoie le formulaire : POST pour ajouter, PUT pour modifier
async function enregistrer(event) {
  event.preventDefault();
  masquerErreur();

  const nom = document.getElementById('nom').value.trim();
  if (!nom) {
    afficherErreur('Le nom de la catégorie est obligatoire.');
    return;
  }

  let url = API_BACKOFFICE_URL;
  let methode = 'POST';
  if (mode === 'modifier') {
    if (!categorieChoisie) {
      afficherErreur('Choisissez la catégorie à modifier.');
      return;
    }
    url = `${API_BACKOFFICE_URL}/${categorieChoisie.id}`;
    methode = 'PUT';
  }

  try {
    const response = await fetch(url, {
      method: methode,
      headers: getHeaders(true),
      body: JSON.stringify({ name: nom })
    });

    if (response.ok) {
      window.location.href = 'GestionCategorie.html';
    } else {
      // Ex : nom déjà utilisé, nom vide...
      afficherErreur(await getErrorMessage(response));
    }
  } catch (error) {
    console.error("Erreur réseau lors de l'enregistrement :", error);
    afficherErreur('Impossible de joindre le serveur.');
  }
}

function afficherErreur(texte) {
  const message = document.getElementById('message');
  message.textContent = texte;
  message.hidden = false;
}

function masquerErreur() {
  document.getElementById('message').hidden = true;
}
