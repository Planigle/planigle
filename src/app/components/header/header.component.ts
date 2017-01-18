import { Component, AfterViewInit } from '@angular/core';
import { SessionsService } from '../../services/sessions.service';
import { ProjectsService } from '../../services/projects.service';
import { IndividualsService } from '../../services/individuals.service';
import { Project } from '../../models/project';
import { Individual } from '../../models/individual';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.css'],
  providers: [ ProjectsService, IndividualsService ]
})
export class HeaderComponent implements AfterViewInit {
  projects: Project[] = [];

  constructor(
    private sessionsService: SessionsService,
    private projectsService: ProjectsService,
    private IndividualsService: IndividualsService
  ) { }

  ngAfterViewInit(): void {
    this.fetchProjects();
  }

  private fetchProjects(): void {
    this.projectsService.getProjects()
      .subscribe(
        (projects: Project[]) => this.projects = projects);
  }

  get user(): Individual {
    return this.sessionsService.getCurrentUser();
  }

  logout(): void {
    this.sessionsService.logout();
  }

  updateProject(): void {
    this.IndividualsService.update(this.user).subscribe(
      (individual: Individual) => {
        location.reload();
      });
  }
}
