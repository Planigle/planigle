import { Component, AfterViewInit } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { GridOptions } from 'ag-grid/main';
import { TeamActionsComponent } from '../team-actions/team-actions.component';
import { CompaniesService } from '../../services/companies.service';
import { ProjectsService } from '../../services/projects.service';
import { TeamsService } from '../../services/teams.service';
import { SessionsService } from '../../services/sessions.service';
import { Organization } from '../../models/organization';
import { Company } from '../../models/company';
import { Project } from '../../models/project';
import { Team } from '../../models/team';
import { Individual } from '../../models/individual';
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-teams',
  templateUrl: './teams.component.html',
  styleUrls: ['./teams.component.css'],
  providers: [CompaniesService, ProjectsService, TeamsService]
})
export class TeamsComponent implements AfterViewInit {
  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private sessionsService: SessionsService,
    private companiesService: CompaniesService,
    private projectsService: ProjectsService,
    private teamsService: TeamsService
  ) { }

  public gridOptions: GridOptions = <GridOptions>{};
  public columnDefs: any[] = [{
    headerName: '',
    width: 20,
    field: 'blank',
    cellRenderer: 'group',
    suppressMovable: true,
    suppressResize: true,
    suppressSorting: true
  }, {
    headerName: '',
    width: 54,
    field: 'blank',
    cellRendererFramework: TeamActionsComponent,
    suppressMovable: true,
    suppressResize: true,
    suppressSorting: true
  }, {
    headerName: 'Name',
    width: 300,
    field: 'name'
  }, {
    headerName: 'Description',
    width: 400,
    field: 'description'
  }];
  public companies: Company[] = null;
  public selection: Organization;
  public user: Individual;
  private id_map: Map<string,Organization> = new Map();
 
  ngAfterViewInit(): void {
    let self = this;
    this.setGridHeight();
    $(window).resize(this.setGridHeight);
    this.user = new Individual(this.sessionsService.getCurrentUser());
    this.route.params.subscribe((params:Map<string,string>) => this.applyNavigation(params));
  }
      
  ngOnDestroy(): void {
    $(window).off('resize');
  }
  
  private setGridHeight(): void {
    $('app-teams ag-grid-ng2').height(($(window).height() - $('app-header').height() - 70) * 0.4);
  }
  
  private fetchCompanies(afterAction, afterActionParams): void {
    let self: TeamsComponent = this;
    this.companiesService.getCompanies()
      .subscribe(
        (companies: Company[]) => {
          companies.forEach((company: Company) => {
            self.id_map[company.uniqueId] = company;
            company.projects.forEach((project: Project) => {
              self.id_map[project.uniqueId] = project;
              project.teams.forEach((team: Team) => {
                self.id_map[team.uniqueId] = team;
              });
            });
          });
          this.companies = companies;
          if(afterAction) {
            afterAction.call(this, afterActionParams);
          }
        });
  }
    
  private applyNavigation(params: Map<string,string>): void {
    if(this.companies) {
      this.setSelection(params['organization']);
    } else {
      this.fetchCompanies(this.setSelection, params['organization']);
    }
  }
  
  private setSelection(selectionValue: string): void {
    let selection: Organization = null;
    if(('' + selectionValue).search(/NewProject\{C\d+\}/i) == 0) {
      let company: Company = this.id_map[selectionValue.substring(10, selectionValue.length - 1)];
      if(company) {
        selection = new Project({
          company: company,
          company_id: company.id,
          track_actuals: false,
          survey_mode: 1
        });
      }
    } else if(('' + selectionValue).search(/NewTeam\{P\d+\}/i) == 0) {
      let project: Project = this.id_map[selectionValue.substring(7, selectionValue.length - 1)];
      if(project) {
        selection = new Team({
          project: project,
          project_id: project.id
        });
      }
    } else {
      selection = this.id_map[selectionValue];
    }
    this.selection = selection ? selection : null;
  }
  
  rowGroupOpened(event: any): void {
    event.node.data.expanded = event.node.expanded;
  }
  
  addProject(company: Company): void {
    this.router.navigate(['people', {organization: 'NewProject(' + company.id + ')'}]);
  }
    
  addTeam(project: Project): void {
    this.router.navigate(['people', {organization: 'NewTeam(' + project.id + ')'}]);
  }
  
  private editRow(event): void {
    this.editOrganization(event.data);
  }
  
  editOrganization(organization: Organization): void {
    this.router.navigate(['people', {organization: organization.uniqueId}]);
  }
      
  deleteProject(project: Project): void {
    this.projectsService.delete(project).subscribe(
      (deletedProject: any) => {
        project.company.projects.splice(project.company.projects.indexOf(project), 1);
        this.companies = this.companies.slice(0); // Force ag-grid to deal with change in rows
      }
    );
  }
          
  deleteTeam(team: Team): void {
    this.teamsService.delete(team).subscribe(
      (deletedTeam: any) => {
        team.project.teams.splice(team.project.teams.indexOf(team), 1);
        this.companies = this.companies.slice(0); // Force ag-grid to deal with change in rows
      }
    );
  }
    
  get context(): any {
    return {
      me: this.user,
      gridHolder: this
    };
  }
  
  getChildren(rowItem: Organization): any {
    if(rowItem.isCompany()) {
      let company: Company = <Company> rowItem;
      if(company.projects && company.projects.length > 0) {
        return {
          group: true,
          children: company.projects,
          expanded: rowItem.expanded
        };
      } else {
        return null;
      }
    } else if(rowItem.isProject()) {
      let project: Project = <Project> rowItem;
      if(project.teams && project.teams.length > 0) {
        return {
          group: true,
          children: project.teams,
          expanded: rowItem.expanded
        };
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
    
  getRowClass(rowItem: any): string {
    return rowItem.data.isCompany() ? 'company' : (rowItem.data.isProject() ? 'project' : 'team');
  }
  
  finishedEditing(result: FinishedEditing): void {
    if (this.selection) {
      if (this.selection.added) {
        this.selection.added = false;
        if(this.selection.isTeam()) {
          let team: Team = <Team> this.selection;
          this.id_map[team.uniqueId] = team;
          team.project.teams.push(team);
        } else {
          let project: Project = <Project> this.selection;
          this.id_map[project.uniqueId] = project;
          project.company.projects.push(project);
        }
        this.gridOptions.api.setRowData(this.companies);
      } else {
        this.gridOptions.api.refreshView();
      }
    }
    switch (result) {
      case FinishedEditing.AddAnother:
        if(this.selection.isTeam()) {
          this.setSelection('NewTeam(' + (<Team>this.selection).project.id + ')');
        } else {
          this.setSelection('NewProject(');
        }
        break;
      case FinishedEditing.Save:
      case FinishedEditing.Cancel:
        this.router.navigate(['people']);
        break;
    }
  }
}
