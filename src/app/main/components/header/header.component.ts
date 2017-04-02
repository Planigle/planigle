import { Component, AfterViewInit, Input } from '@angular/core';
import { SessionsService } from '../../services/sessions.service';
import { CompaniesService } from '../../services/companies.service';
import { ProjectsService } from '../../services/projects.service';
import { IndividualsService } from '../../services/individuals.service';
import { PremiumService } from '../../../premium/services/premium.service';
import { Company } from '../../models/company';
import { Project } from '../../models/project';
import { Individual } from '../../models/individual';
import { Notifier } from '../../models/notifier';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.css'],
  providers: [ CompaniesService, ProjectsService, IndividualsService, PremiumService ]
})
export class HeaderComponent implements AfterViewInit {
  @Input() notifier: Notifier;
  projects: Project[] = [];
  companies: Company[] = [];

  constructor(
    private sessionsService: SessionsService,
    private companiesService: CompaniesService,
    private projectsService: ProjectsService,
    private IndividualsService: IndividualsService,
    private premiumService: PremiumService
  ) { }

  ngAfterViewInit(): void {
    this.fetchCompanies();
    this.fetchProjects();
    if (this.notifier) {
      let self: HeaderComponent = this;
      this.notifier.addClient(function() {
        self.fetchProjects();
      });
    }
  }

  private fetchCompanies(): void {
    if (this.sessionsService.getCurrentUser().canChangeCompany()) {
      this.companiesService.getRecentCompanies()
        .subscribe(
          (companies: Company[]) => this.companies = companies);
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

  updateCompany(): void {
    this.companies.forEach((company: Company) => {
      if (company.id === this.user.company_id) {
        this.user.selected_project_id = company.projects[0].id;
      }
    });
    this.IndividualsService.updateCompany(this.user).subscribe(
      (individual: Individual) => {
        location.reload();
      });
  }

  updateProject(): void {
    this.IndividualsService.updateProject(this.user).subscribe(
      (individual: Individual) => {
        location.reload();
      });
  }
}
