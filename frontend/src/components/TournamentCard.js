import React from 'react';

function TournamentCard({ tournament }) {
  // Placeholder content - replace with actual card structure
  return (
    <div style={{ border: '1px solid #ccc', margin: '10px', padding: '10px' }}>
      <h3>{tournament?.name || 'Tournament Name'}</h3>
      <p>Status: {tournament?.status || 'Upcoming'}</p>
      {/* Add more details as needed */}
    </div>
  );
}

export default TournamentCard; 