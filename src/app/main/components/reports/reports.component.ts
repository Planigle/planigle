import { Component, OnInit } from '@angular/core';
import { SessionsService } from '../../services/sessions.service';
import { TeamsService } from '../../services/teams.service';
import { ReleasesService } from '../../services/releases.service';
import { IterationsService } from '../../services/iterations.service';
import { Team } from '../../models/team';
import { Individual } from '../../models/individual';
import { Release } from '../../models/release';
import { Iteration } from '../../models/iteration';

@Component({
  selector: 'app-reports',
  templateUrl: './reports.component.html',
  styleUrls: ['./reports.component.css'],
  providers: [TeamsService, ReleasesService, IterationsService]
})
export class ReportsComponent implements OnInit {
  user: Individual;
  teams: Team[] = [];
  releases: Release[] = [];
  iterations: Iteration[] = [];

  constructor(
    private sessionsService: SessionsService,
    private teamsService: TeamsService,
    private releasesService: ReleasesService,
    private iterationsService: IterationsService
    ) {}

  ngOnInit(): void {
    this.user = this.sessionsService.getCurrentUser();
    this.teamsService.getTeams(this.user.selected_project_id).subscribe((teams: Team[]) => {
      teams.push(new Team({name: 'No Team', id: ''}));
      teams.push(new Team({name: 'All Teams', id: 'All'}));
      this.teams = teams;
    });
    this.releasesService.getReleases(true).subscribe((releases: Release[]) => {
      this.releases = releases;
    });
    this.iterationsService.getIterations(true).subscribe((iterations: Iteration[]) => {
      this.iterations = iterations;
    });
  }
}
