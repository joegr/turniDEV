from project.tournament.models import Team, Tournament, Match

class KnockoutService:
    def __init__(self, tournament):
        self.tournament = tournament

    def initialize_knockout_stage(self, qualified_teams):
        """
        Initialize the knockout stage with qualified teams from group stage
        """
        if len(qualified_teams) != self.tournament.knockout_teams:
            raise ValueError(
                f"Expected {self.tournament.knockout_teams} teams, "
                f"got {len(qualified_teams)}"
            )

        # Create knockout matches based on seeding
        matches = self._create_initial_matches(qualified_teams)
        return matches

    def _create_initial_matches(self, qualified_teams):
        """
        Create the initial knockout matches based on team seedings
        """
        matches = []
        num_matches = len(qualified_teams) // 2
        
        for i in range(num_matches):
            # Pair first with last, second with second-last, etc.
            home_team = qualified_teams[i]
            away_team = qualified_teams[-(i+1)]
            
            match = KnockoutMatch.objects.create(
                tournament=self.tournament,
                team_home=home_team,
                team_away=away_team,
                round=1  # First round
            )
            matches.append(match)
        
        return matches 