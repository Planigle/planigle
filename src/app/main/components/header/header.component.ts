import { Component, AfterViewInit, Input } from '@angular/core';
import { SessionsService } from '../../services/sessions.service';
import { ProjectsService } from '../../services/projects.service';
import { IndividualsService } from '../../services/individuals.service';
import { PremiumService } from '../../../premium/services/premium.service';
import { Project } from '../../models/project';
import { Individual } from '../../models/individual';
import { Notifier } from '../../models/notifier';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.css'],
  providers: [ ProjectsService, IndividualsService, PremiumService ]
})
export class HeaderComponent implements AfterViewInit {
  @Input() notifier: Notifier;
  projects: Project[] = [];

  constructor(
    private sessionsService: SessionsService,
    private projectsService: ProjectsService,
    private IndividualsService: IndividualsService,
    private premiumService: PremiumService
  ) { }

  ngAfterViewInit(): void {
    this.fetchProjects();
    if (this.notifier) {
      let self: HeaderComponent = this;
      this.notifier.addClient(function() {
        self.fetchProjects();
      });
    }
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
    this.IndividualsService.updateProject(this.user).subscribe(
      (individual: Individual) => {
        location.reload();
      });
  }
}
