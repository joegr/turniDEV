import React, { useState, useEffect } from 'react';
import { fetchMatchDetails } from '../services/matchService'; // Uncommented
import { useParams } from 'react-router-dom'; // Uncommented

function MatchDetailView() {
  const { matchId } = useParams(); // Use hook to get ID from URL
  // const matchId = 1; // Placeholder removed

  const [match, setMatch] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Use actual API call
    fetchMatchDetails(matchId)
      .then(data => {
        setMatch(data);
        setLoading(false);
      })
      .catch(err => {
        console.error(err);
        setError(`Failed to load match details: ${err.message}`);
        setLoading(false);
      });

    // Simulate API call removed
    // setTimeout(() => {
    //   setMatch({ id: matchId, team1: 'Team A', team2: 'Team B', score1: 2, score2: 1, status: 'Finished', startTime: '2023-10-27T10:00:00Z' });
    //   setLoading(false);
    // }, 1000);

  }, [matchId]); // Dependency array includes matchId

  if (loading) return <div>Loading match details...</div>;
  if (error) return <div>{error}</div>;
  if (!match) return <div>Match not found.</div>

  return (
    <div>
      <h2>Match Details</h2>
      <p>{match.team1} vs {match.team2}</p>
      <p>Score: {match.score1} - {match.score2}</p>
      <p>Status: {match.status}</p>
      <p>Time: {match.startTime ? new Date(match.startTime).toLocaleString() : 'Not scheduled'}</p>
      {/* Add more match details as needed */}
    </div>
  );
}

export default MatchDetailView; 