import { Component, OnInit, AfterViewInit, OnDestroy, Output, EventEmitter } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { GridOptions } from 'ag-grid/main';
import { ConfirmationDialogComponent } from '../confirmation-dialog/confirmation-dialog.component';
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
export class TeamsComponent implements OnInit, AfterViewInit, OnDestroy {
  @Output() projectsChanged: EventEmitter<any> = new EventEmitter();
  @Output() teamsChanged: EventEmitter<any> = new EventEmitter();
  public gridOptions: GridOptions = <GridOptions>{};
  public columnDefs: any[] = [];
  public companies: Company[] = null;
  public selection: Organization;
  public user: Individual;
  public editing: boolean = false;
  private id_map: Map<string, Organization> = new Map();

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private modalService: NgbModal,
    private sessionsService: SessionsService,
    private companiesService: CompaniesService,
    private projectsService: ProjectsService,
    private teamsService: TeamsService
  ) { }

  ngOnInit(): void {
    this.user = new Individual(this.sessionsService.getCurrentUser());
  }

  ngAfterViewInit(): void {
    this.setGridHeight();
    $(window).resize(this.setGridHeight);
    this.route.params.subscribe((params: Map<string, string>) => this.applyNavigation(params));
    this.columnDefs = [{
      headerName: '',
      width: 20,
      field: 'blank',
      cellRenderer: 'group',
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
  }

  ngOnDestroy(): void {
    $(window).off('resize');
  }

  private setGridHeight(): void {
    $('app-teams ag-grid-ng2').height(($(window).height() - $('app-header').height() - 57) * 0.4);
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
          if (afterAction) {
            afterAction.call(this, afterActionParams);
          }
        });
  }

  private applyNavigation(params: Map<string, string>): void {
    if (this.companies) {
      this.setSelection(params['organization']);
    } else {
      this.fetchCompanies(this.setSelection, params['organization']);
    }
    this.editing = params['individual'] != null;
  }

  gridReady(): void {
    $.contextMenu(this.getMenu('.company', 'Project', this.addProjectItem));
    $.contextMenu(this.getMenu('.project', 'Team', this.addTeamItem));
    $.contextMenu(this.getMenu('.team', null, null));
  }

  private getMenu(selector: string, childName: string, childFunction: any): any {
    let self: TeamsComponent = this;
    let menu = {
      selector: selector,
      items: {
        edit: {
          name: 'Edit',
          callback: function(key, opt) { self.editItem(self.getItem(this)); }
        }
      }
    };
    if (this.user.canChangePeople()) {
      if (childName != null) {
        menu['items']['addChild'] = {
          name: 'Add ' + childName,
          callback: function(key, opt) { childFunction.call(self, self.getItem(this)); }
        };
      }
      if (selector !== '.company') {
        menu['items']['deleteItem'] = {
          name: 'Delete',
          callback: function(key, opt) { self.deleteItem(self.getItem(this)); }
        };
      }
    }
    return menu;
  }

  private getItem(jQueryObject: any): Organization {
    let result: string = null;
    $.each(jQueryObject.attr('class').toString().split(' '), function (i: number, className: string) {
      if (className.indexOf('id-') === 0) {
        result = className.substring(3);
      }
    });
    return this.id_map[result];
  }

  addProjectItem(model: Organization): void {
    this.addProject(<Company> model);
  }

  addTeamItem(model: Organization): void {
    this.addTeam(<Project> model);
  }

  editItem(model: Organization): void {
    this.editOrganization(model);
  }

  deleteItem(model: Organization): void {
    let self: TeamsComponent = this;
    const modalRef: NgbModalRef = this.modalService.open(ConfirmationDialogComponent);
    let component: ConfirmationDialogComponent = modalRef.componentInstance;
    component.confirmDelete(model.isTeam() ? 'Team' : 'Project', model.name);
    modalRef.result.then(
      (result: any) => {
        if (component.model.confirmed) {
          if (model.isTeam()) {
            self.deleteTeam(<Team> model);
          } else {
            self.deleteProject(<Project> model);
          }
        }
      }
    );
  }

  private setSelection(selectionValue: string): void {
    let selection: Organization = null;
    if (('' + selectionValue).search(/NewProject\{C\d+\}/i) === 0) {
      let company: Company = this.id_map[selectionValue.substring(11, selectionValue.length - 1)];
      if (company) {
        selection = new Project({
          company: company,
          company_id: company.id,
          track_actuals: false,
          survey_mode: 1
        });
      }
    } else if (('' + selectionValue).search(/NewTeam\{P\d+\}/i) === 0) {
      let project: Project = this.id_map[selectionValue.substring(8, selectionValue.length - 1)];
      if (project) {
        selection = new Team({
          project: project,
          project_id: project.id
        });
      }
    } else {
      selection = this.id_map[selectionValue];
    }
    this.selection = selection;
  }

  rowGroupOpened(event: any): void {
    event.node.data.expanded = event.node.expanded;
  }

  addProject(company: Company): void {
    this.router.navigate(['people', {organization: 'NewProject{C' + company.id + '}'}]);
  }

  addTeam(project: Project): void {
    this.router.navigate(['people', {organization: 'NewTeam{P' + project.id + '}'}]);
  }

  editRow(event): void {
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
        this.projectsChanged.emit();
      }
    );
  }

  deleteTeam(team: Team): void {
    this.teamsService.delete(team).subscribe(
      (deletedTeam: any) => {
        team.project.teams.splice(team.project.teams.indexOf(team), 1);
        this.companies = this.companies.slice(0); // Force ag-grid to deal with change in rows
        this.teamsChanged.emit();
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
    if (rowItem.isCompany()) {
      let company: Company = <Company> rowItem;
      if (company.projects && company.projects.length > 0) {
        return {
          group: true,
          children: company.projects,
          expanded: rowItem.expanded
        };
      } else {
        return null;
      }
    } else if (rowItem.isProject()) {
      let project: Project = <Project> rowItem;
      if (project.teams && project.teams.length > 0) {
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
    return (rowItem.data.isCompany() ? 'company' : (rowItem.data.isProject() ? 'project' : 'team')) +
      ' id-' + rowItem.data.uniqueId;
  }

  finishedEditing(result: FinishedEditing): void {
    let selection: Organization = this.selection;
    if (selection) {
      if (selection.added) {
        selection.added = false;
        if (selection.isTeam()) {
          let team: Team = <Team> selection;
          this.id_map[team.uniqueId] = team;
          team.project.expanded =  true;
          team.project.teams.push(team);
          this.teamsChanged.emit();
        } else {
          let project: Project = <Project> selection;
          this.id_map[project.uniqueId] = project;
          project.company.expanded = true;
          project.company.projects.push(project);
          this.projectsChanged.emit();
        }
        this.gridOptions.api.setRowData(this.companies);
      } else {
        if (selection.isTeam()) {
          this.teamsChanged.emit();
        } else if (selection.isProject()) {
          this.projectsChanged.emit();
        }
        this.gridOptions.api.refreshView();
      }
    }
    switch (result) {
      case FinishedEditing.AddAnother:
        if (selection.isTeam()) {
          this.addTeam((<Team>selection).project);
        } else {
          this.addProject((<Project>selection).company);
        }
        break;
      case FinishedEditing.Save:
      case FinishedEditing.Cancel:
        this.router.navigate(['people']);
        break;
    }
  }
}
