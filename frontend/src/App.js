import React from 'react';
import { Routes, Route, Link } from 'react-router-dom';
import TournamentListView from './views/TournamentListView';
import TournamentDetailView from './views/TournamentDetailView';
import MatchDetailView from './views/MatchDetailView';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1><Link to="/" style={{ color: 'inherit', textDecoration: 'none' }}>Tournament Management System</Link></h1>
        {/* Basic Navigation Example */}
        <nav>
          <Link to="/tournaments">Tournaments</Link>
          {/* Add other links as needed */}
        </nav>
      </header>
      <main>
        <Routes>
          <Route path="/" element={<h2>Welcome! Select a view.</h2>} />
          <Route path="/tournaments" element={<TournamentListView />} />
          <Route path="/tournaments/:tournamentId" element={<TournamentDetailView />} />
          <Route path="/matches/:matchId" element={<MatchDetailView />} />
          {/* You might want a more nested route like /tournaments/:tournamentId/matches/:matchId */}
        </Routes>
      </main>
    </div>
  );
}

export default App; 