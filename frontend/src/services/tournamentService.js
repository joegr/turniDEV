// Placeholder for tournament API calls

const API_BASE_URL = process.env.REACT_APP_API_URL || '/api'; // Get base URL from env var or default

export const fetchTournaments = async () => {
  // Replace with actual fetch call to your backend API
  // Example: const response = await fetch(`${API_BASE_URL}/tournaments`);
  console.log('Fetching tournaments...');
  // Simulate API delay and return mock data
  await new Promise(resolve => setTimeout(resolve, 500));
  return [
    { id: 1, name: 'API Tournament 1', status: 'Ongoing' },
    { id: 2, name: 'API Tournament 2', status: 'Upcoming' },
  ];
  // if (!response.ok) {
  //   throw new Error('Network response was not ok');
  // }
  // return response.json();
};

export const fetchTournamentDetails = async (tournamentId) => {
  // Replace with actual fetch call
  // Example: const response = await fetch(`${API_BASE_URL}/tournaments/${tournamentId}`);
  console.log(`Fetching details for tournament ${tournamentId}...`);
  await new Promise(resolve => setTimeout(resolve, 500));
  return {
    id: tournamentId,
    name: `API Tournament ${tournamentId}`,
    status: 'Ongoing',
    description: 'Detailed description from API...',
    teams: [{ id: 1, name: 'Team Alpha' }, { id: 2, name: 'Team Beta' }],
    matches: [{ id: 101, team1: 'Team Alpha', team2: 'Team Beta', score1: 0, score2: 0, status: 'Pending' }],
  };
  // if (!response.ok) {
  //   throw new Error('Network response was not ok');
  // }
  // return response.json();
};

// Add functions for creating, updating, deleting tournaments as needed 