// Détermine le badge d'une activité : disponible, complet ou indisponible
function getStatutAtelier(workshop) {
  if (workshop.capacityMax === 0) {
    return { classe: 'badge-indispo', texte: 'Indisponible ⊘' };
  }
  if (workshop.subscriberNumber >= workshop.capacityMax) {
    return { classe: 'badge-complet', texte: 'Complet ✕' };
  }
  return { classe: 'badge-dispo', texte: 'Disponible ✓' };
}

// Badge d'une réservation : validée, en attente ou annulée
function getStatutReservation(status) {
  if (status === 'validated') return { classe: 'badge-dispo', texte: 'Validée ✓' };
  if (status === 'pending') return { classe: 'badge-attente', texte: 'En attente' };
  return { classe: 'badge-complet', texte: 'Annulée ✕' };
}

// Range les réservations d'un utilisateur en 3 listes :
// à venir, historique (atelier terminé) et annulées (jamais supprimées)
function classerReservations(reservations) {
  const maintenant = new Date();
  const resultat = { upcoming: [], history: [], cancelled: [] };

  reservations.forEach(reservation => {
    if (reservation.status === 'cancelled') {
      resultat.cancelled.push(reservation);
    } else if (new Date(reservation.endTime) < maintenant) {
      resultat.history.push(reservation);
    } else {
      resultat.upcoming.push(reservation);
    }
  });
  return resultat;
}
