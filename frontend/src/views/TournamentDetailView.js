import React, { useState, useEffect } from 'react';
import { fetchTournamentDetails } from '../services/tournamentService'; // Uncommented
import { useParams } from 'react-router-dom'; // Uncommented

function TournamentDetailView() {
  const { tournamentId } = useParams(); // Use hook to get ID from URL
  // const tournamentId = 1; // Placeholder removed

  const [tournament, setTournament] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Use actual API call
    fetchTournamentDetails(tournamentId)
      .then(data => {
        setTournament(data);
        setLoading(false);
      })
      .catch(err => {
        console.error(err); // Log error for debugging
        setError(`Failed to load tournament details: ${err.message}`);
        setLoading(false);
      });

    // Simulate API call removed
    // setTimeout(() => {
    //   setTournament({ id: tournamentId, name: 'Demo Tournament 1', status: 'Ongoing', description: 'Details about this tournament...', teams: [], matches: [] });
    //   setLoading(false);
    // }, 1000);

  }, [tournamentId]); // Dependency array includes tournamentId

  if (loading) return <div>Loading tournament details...</div>;
  if (error) return <div>{error}</div>;
  if (!tournament) return <div>Tournament not found.</div>

  return (
    <div>
      <h2>{tournament.name}</h2>
      <p>Status: {tournament.status}</p>
      <p>{tournament.description}</p>
      {/* Add sections for teams, matches/brackets, etc. */}
      <h3>Teams</h3>
      {/* List teams - Placeholder for now */}
      {tournament.teams?.length > 0 ? (
        <ul>
          {tournament.teams.map(team => <li key={team.id}>{team.name}</li>)}
        </ul>
      ) : <p>No teams found.</p>}
      <h3>Matches</h3>
      {/* Display bracket or match list - Placeholder for now */}
      {tournament.matches?.length > 0 ? (
         <ul>
           {tournament.matches.map(match => <li key={match.id}>{match.team1} vs {match.team2} - Status: {match.status}</li>)}
         </ul>
       ) : <p>No matches found.</p>}
    </div>
  );
}

export default TournamentDetailView; 