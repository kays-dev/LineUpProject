// Catégories : lecture pour tout le monde connecté, suppression réservée au staff
const API_URL = API_BASE + '/categories'; // lecture
const API_BACKOFFICE_URL = API_BASE + '/backoffice/categories'; // suppression (staff uniquement)

verifierConnexion();

document.addEventListener('DOMContentLoaded', fetchCategories);

// Récupère les catégories (déjà triées par nom côté Vapor)
async function fetchCategories() {
  try {
    const response = await fetch(API_URL, { headers: getHeaders() });
    if (!response.ok) {
      throw new Error(`Erreur HTTP : ${response.status}`);
    }
    const categories = await response.json();
    renderCategoriesTable(categories);

  } catch (error) {
    console.error('Impossible de récupérer les catégories :', error);
    const tbody = document.getElementById('categoryTable');
    tbody.innerHTML = `<tr><td colspan="2" class="table-message erreur">Erreur de chargement des données du serveur.</td></tr>`;
  }
}

// Remplit le tableau avec les catégories reçues
function renderCategoriesTable(categories) {
  const tbody = document.getElementById('categoryTable');
  tbody.innerHTML = '';

  document.getElementById('pageSubtitle').textContent = `${categories.length} types d'activité`;

  if (categories.length === 0) {
    tbody.innerHTML = `<tr><td colspan="2" class="table-message">Aucune catégorie pour le moment.</td></tr>`;
    return;
  }

  categories.forEach(category => {
    const tr = document.createElement('tr');
    // Le bouton modifier ouvre le formulaire directement sur cette catégorie
    tr.innerHTML = `
      <td>${escapeHtml(category.name)}</td>
      <td>
        <div class="actions">
          <a href="FormulaireCategorie.html?id=${category.id}" class="action-btn" title="Modifier">${ICONE_MODIFIER}</a>
          <a href="#" class="action-btn delete" onclick="deleteCategory('${category.id}'); return false;" title="Supprimer">${ICONE_SUPPRIMER}</a>
        </div>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

// Supprime une catégorie (DELETE /backoffice/categories/:id)
async function deleteCategory(id) {
  // Boîte de confirmation (même visuel que la maquette Figma)
  const confirme = await confirmer({
    titre: 'Supprimer la catégorie ?',
    texte: 'La catégorie sera définitivement supprimée.',
    boutonConfirmer: 'SUPPRIMER'
  });
  if (!confirme) return;

  try {
    const response = await fetch(`${API_BACKOFFICE_URL}/${id}`, {
      method: 'DELETE',
      headers: getHeaders()
    });

    if (response.ok) {
      fetchCategories();
    } else {
      // Ex : le serveur refuse si la catégorie est encore utilisée par des activités
      await afficherAlerte(await getErrorMessage(response));
    }
  } catch (error) {
    console.error('Erreur réseau lors de la suppression :', error);
  }
}
