import React, { useState, useEffect } from 'react';
import TournamentCard from '../components/TournamentCard';
import { fetchTournaments } from '../services/tournamentService'; // Uncommented
import { Link } from 'react-router-dom'; // Import Link

function TournamentListView() {
  const [tournaments, setTournaments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Use actual API call
    fetchTournaments()
      .then(data => {
        setTournaments(data);
        setLoading(false);
      })
      .catch(err => {
        console.error(err);
        setError(`Failed to load tournaments: ${err.message}`);
        setLoading(false);
      });

    // Simulate API call removed
    // setTimeout(() => {
    //   setTournaments([{ id: 1, name: 'Demo Tournament 1', status: 'Ongoing' }, { id: 2, name: 'Demo Tournament 2', status: 'Finished' }]);
    //   setLoading(false);
    // }, 1000);

  }, []);

  if (loading) return <div>Loading tournaments...</div>;
  if (error) return <div>{error}</div>;

  return (
    <div>
      <h2>Tournaments</h2>
      {tournaments.length > 0 ? (
        tournaments.map(tournament => (
          // Wrap card in a Link to the detail view
          <Link key={tournament.id} to={`/tournaments/${tournament.id}`} style={{ textDecoration: 'none', color: 'inherit' }}>
            <TournamentCard tournament={tournament} />
          </Link>
        ))
      ) : (
        <p>No tournaments found.</p>
      )}
    </div>
  );
}

export default TournamentListView; 