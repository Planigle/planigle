import { Component, OnInit } from '@angular/core';
import { SessionsService } from '../../services/sessions.service';
import { TeamsService } from '../../services/teams.service';
import { Team } from '../../models/team';
import { Individual } from '../../models/individual';

@Component({
  selector: 'app-reports',
  templateUrl: './reports.component.html',
  styleUrls: ['./reports.component.css'],
  providers: [TeamsService]
})
export class ReportsComponent implements OnInit {
  user: Individual;
  teams: Team[] = [];

  constructor(
    private sessionsService: SessionsService,
    private teamsService: TeamsService
  ) {}

  ngOnInit(): void {
    this.user = this.sessionsService.getCurrentUser();
    this.teamsService.getTeams(this.user.selected_project_id).subscribe((teams: Team[]) => {
      this.teams = teams;
    });
  }
}
