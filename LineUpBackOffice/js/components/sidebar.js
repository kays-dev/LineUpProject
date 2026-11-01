// Affiche le nom et le rôle de la personne connectée en bas du menu
async function chargerUtilisateur() {
  const nom = document.getElementById('sidebarName');
  const role = document.getElementById('sidebarRole');
  if (!nom) return;

  try {
    const response = await fetch(`${API_BASE}/appios/users/me`, { headers: getHeaders() });
    if (!response.ok) return;
    const user = await response.json();
    nom.textContent = user.name.toUpperCase();
    role.textContent = user.role === 'staff' ? 'Admin' : 'Festivalier';
  } catch (error) {
    console.error("Impossible de récupérer l'utilisateur connecté :", error);
  }
}

// Quand la page est chargée, on remplit le menu
document.addEventListener('DOMContentLoaded', chargerUtilisateur);
