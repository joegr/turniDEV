from .knockout_stage import KnockoutService
from project.tournament.models import Match, Team, GroupStageMatch

class GroupStageService:
    def __init__(self, tournament):
        self.tournament = tournament

    def calculate_team_statistics(self):
        stats = {
            team.info: {
                'team': team,
                'matches_played': 0,
                'wins': 0,
                'draws': 0,
                'losses': 0,    
                'goals_for': 0,
                'goals_against': 0,
                'points': 0
            }

            for team in self.get_group_teams()
        }
        
        for match in self.get_group_matches():
            if match.is_completed:
                self._update_match_statistics(match, stats)
        
        return stats

    def _update_match_statistics(self, match, stats):
        home_stats = stats[match.team_home.info]
        away_stats = stats[match.team_away.info]
        
        home_stats['matches_played'] += 1
        away_stats['matches_played'] += 1
        
        home_stats['goals_for'] += match.home_score
        home_stats['goals_against'] += match.away_score
        away_stats['goals_for'] += match.away_score
        away_stats['goals_against'] += match.home_score
        
        if match.home_score > match.away_score:
            home_stats['wins'] += 1
            home_stats['points'] += 3
            away_stats['losses'] += 1
        elif match.home_score < match.away_score:
            away_stats['wins'] += 1
            away_stats['points'] += 3
            home_stats['losses'] += 1
        else:
            home_stats['draws'] += 1
            away_stats['draws'] += 1
            home_stats['points'] += 1
            away_stats['points'] += 1

    def transition_to_knockout_stage(self):
        if not self.are_all_group_matches_completed():
            raise ValueError("All group matches must be completed before transitioning")
            
        team_stats = self.calculate_team_statistics()
        qualified_teams = self._get_qualified_teams(team_stats)
        
        knockout_service = KnockoutService(self.tournament)
        return knockout_service.initialize_knockout_stage(qualified_teams)

    def are_all_group_matches_completed(self):
        return not GroupStageMatch.objects.filter(
            tournament=self.tournament,
            is_completed=False
        ).exists()

    def get_group_teams(self):
        return Team.objects.filter(tournament=self.tournament)

    def get_group_matches(self):
        return GroupStageMatch.objects.filter(tournament=self.tournament)

    def _get_qualified_teams(self, team_stats):
        # Sort teams by points, then goal difference, then goals scored
        sorted_teams = sorted(
            team_stats.values(),
            key=lambda x: (
                x['points'],
                x['goals_for'] - x['goals_against'],
                x['goals_for']
            ),
            reverse=True
        )
        # Return top teams (number depends on tournament configuration)
        return [stats['team'] for stats in sorted_teams[:self.tournament.knockout_teams]] 