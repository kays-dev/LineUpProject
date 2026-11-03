// Remplacent confirm() et alert() du navigateur (visuel de la maquette Figma ).

// Icones du rond rouge clair (poubelle pour une suppression, point d'exclamation pour une erreur)
const ICONE_DIALOGUE_POUBELLE = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>';

const ICONE_DIALOGUE_ALERTE = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>';

// Affiche la boite et renvoie une promesse : true si on clique sur le bouton principal, false sinon.

function confirmer({ titre, texte, boutonConfirmer = 'CONFIRMER', boutonAnnuler = 'ANNULER', icone = ICONE_DIALOGUE_POUBELLE, sansAnnuler = false }) {
  return new Promise(resolve => {
    // Fond sombre qui recouvre la page
    const fond = document.createElement('div');
    fond.className = 'modal-overlay';

    // Carte blanche (le texte vient du code, mais on échappe le texte venant du serveur)
    fond.innerHTML = `
      <div class="modal-dialog" role="dialog" aria-modal="true">
        <div class="modal-head">
          <div class="modal-icon">${icone}</div>
          <p class="modal-title">${escapeHtml(titre)}</p>
        </div>
        <p class="modal-text">${escapeHtml(texte)}</p>
        <div class="modal-actions">
          ${sansAnnuler ? '' : `<button type="button" class="btn btn-secondary modal-btn" data-reponse="non">${escapeHtml(boutonAnnuler)}</button>`}
          <button type="button" class="btn btn-primary modal-btn" data-reponse="oui">${escapeHtml(boutonConfirmer)}</button>
        </div>
      </div>
    `;

    // Ferme la boite et donne la réponse
    function fermer(reponse) {
      document.removeEventListener('keydown', toucheClavier);
      fond.remove();
      resolve(reponse);
    }
    function toucheClavier(event) {
      if (event.key === 'Escape') fermer(false);
    }

    fond.addEventListener('click', event => {
      if (event.target === fond) fermer(false);                       
      const bouton = event.target.closest('[data-reponse]');
      if (bouton) fermer(bouton.dataset.reponse === 'oui');
    });
    document.addEventListener('keydown', toucheClavier);

    document.body.appendChild(fond);
    fond.querySelector('[data-reponse="oui"]').focus();
  });
}

// Affiche un message d'erreur 
function afficherAlerte(texte, titre = 'Action impossible') {
  return confirmer({ titre, texte, boutonConfirmer: 'FERMER', icone: ICONE_DIALOGUE_ALERTE, sansAnnuler: true });
}
