import { Component, OnInit, AfterViewInit, OnDestroy, Input } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { GridOptions } from 'ag-grid/main';
import { ConfirmationDialogComponent } from '../confirmation-dialog/confirmation-dialog.component';
import { IndividualsService } from '../../services/individuals.service';
import { CompaniesService } from '../../services/companies.service';
import { SessionsService } from '../../services/sessions.service';
import { Notifier } from '../../models/notifier';
import { Individual } from '../../models/individual';
import { Company } from '../../models/company';
import { Project } from '../../models/project';
import { Team } from '../../models/team';
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-individuals',
  templateUrl: './individuals.component.html',
  styleUrls: ['./individuals.component.css'],
  providers: [IndividualsService, CompaniesService]
})
export class IndividualsComponent implements OnInit, AfterViewInit, OnDestroy {
  @Input() projectNotifier: Notifier;
  @Input() teamNotifier: Notifier;
  public gridOptions: GridOptions = <GridOptions>{};
  public columnDefs: any[] = [];
  public individuals: Individual[] = null;
  public projects: Project[] = [];
  public teams: Team[] = [];
  public selection: Individual;
  public user: Individual;
  public editing: boolean = false;
  private id_map: Map<string, Individual> = new Map();

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private modalService: NgbModal,
    private sessionsService: SessionsService,
    private individualsService: IndividualsService,
    private companiesService: CompaniesService
  ) { }

  ngOnInit(): void {
    this.user = new Individual(this.sessionsService.getCurrentUser());
  }

  ngAfterViewInit(): void {
    this.setGridHeight();
    $(window).resize(this.setGridHeight);
    this.user = new Individual(this.sessionsService.getCurrentUser());
    this.route.params.subscribe((params: Map<string, string>) => this.applyNavigation(params));
    this.columnDefs = [{
      headerName: 'Team',
      width: 100,
      field: 'team_name'
    }, {
      headerName: 'Login',
      width: 100,
      field: 'login'
    }, {
      headerName: 'First Name',
      width: 100,
      field: 'first_name'
    }, {
      headerName: 'Last Name',
      width: 100,
      field: 'last_name'
    }, {
      headerName: 'Role',
      width: 125,
      field: 'role_name'
    }, {
      headerName: 'Activated',
      width: 70,
      field: 'is_activated'
    }, {
      headerName: 'Enabled',
      width: 70,
      field: 'enabled'
    }, {
      headerName: 'Last Logged In',
      width: 150,
      field: 'last_login_string'
    }];
    let self: IndividualsComponent = this;
    if (this.projectNotifier) {
      this.projectNotifier.addClient(function() {
        self.fetchOrganizations();
      });
    }
    if (this.teamNotifier) {
      this.teamNotifier.addClient(function() {
        self.fetchOrganizations();
      });
    }
  }

  ngOnDestroy(): void {
    $(window).off('resize');
  }

  private setGridHeight(): void {
    $('app-individuals ag-grid-ng2').height(($(window).height() - $('app-header').height() - 57) * 0.6);
  }

  private fetchIndividuals(afterAction, afterActionParams): void {
    this.individualsService.getIndividuals()
      .subscribe(
        (individuals: Individual[]) => {
          individuals.forEach((individual: Individual) => {
            this.id_map[individual.id] = individual;
          });
          this.individuals = individuals;
          if (afterAction) {
            afterAction.call(this, afterActionParams);
          }
        });
  }

  private applyNavigation(params: Map<string, string>): void {
    let individualId: string = params['individual'];
    if (this.individuals) {
      this.setSelection(individualId);
    } else {
      this.fetchCompany(individualId);
    }
    this.editing = params['organization'] != null;
  }

  gridReady(): void {
    let self: IndividualsComponent = this;
    let menu = {
      selector: '.individual',
      items: {
        edit: {
        name: 'Edit',
          callback: function(key, opt) { self.editItem(self.getItem(this)); }
        }
      }
    };
    if (this.user.canChangeRelease()) {
      menu['items']['deleteItem'] = {
        name: 'Delete',
        callback: function(key, opt) { self.deleteItem(self.getItem(this)); }
      };
    }
    $.contextMenu(menu);
  }

  getRowClass(rowItem: any): string {
    return 'individual id-' + rowItem.data.id;
  }

  private getItem(jQueryObject: any): Individual {
    let result: string = null;
    $.each(jQueryObject.attr('class').toString().split(' '), function (i: number, className: string) {
      if (className.indexOf('id-') === 0) {
        result = className.substring(3);
      }
    });
    return this.id_map[result];
  }

  editItem(model: Individual): void {
    this.editIndividual(model);
  }

  deleteItem(model: Individual): void {
    let self: IndividualsComponent = this;
    const modalRef: NgbModalRef = this.modalService.open(ConfirmationDialogComponent);
    let component: ConfirmationDialogComponent = modalRef.componentInstance;
    component.confirmDelete('Individual', model.name);
    modalRef.result.then(
      (result: any) => {
        if (component.model.confirmed) {
          self.deleteIndividual(model);
        }
      }
    );
  }

  private fetchCompany(individualId): void {
    let self: IndividualsComponent = this;
    this.companiesService.getCompanies()
      .subscribe(
        (companies: Company[]) => {
          companies.forEach((company: Company) => { // only 1 company
            self.projects = company.projects;
            self.teams = company.getAllTeams();
            this.fetchIndividuals(this.setSelection, individualId);
          });
        });
  }

  private fetchOrganizations(): void {
    let self: IndividualsComponent = this;
    this.companiesService.getCompanies()
      .subscribe(
        (companies: Company[]) => {
          companies.forEach((company: Company) => { // only 1 company
            self.projects = company.projects;
            self.teams = company.getAllTeams();
          });
        });
  }

  private setSelection(individualId: string): void {
    if (individualId) {
      if (individualId === 'New') {
        let project_id = this.user.selected_project_id;
        this.selection = new Individual({
          role: 2,
          enabled: true,
          refresh_interval: 1000 * 60 * 5,
          project_ids: [project_id],
          selected_project_id: project_id,
          team_id: this.user.team_id
        });
      } else {
        this.individuals.forEach((individual: Individual) => {
          if (String(individual.id) === individualId) {
            this.selection = individual;
          }
        });
      }
    } else {
      this.selection = null;
    }
  }

  addIndividual(): void {
    this.router.navigate(['people', {individual: 'New'}]);
  }

  editRow(event): void {
    this.editIndividual(event.data);
  }

  editIndividual(individual: Individual): void {
    this.router.navigate(['people', {individual: individual.id}]);
  }

  deleteIndividual(individual: Individual): void {
    this.individualsService.delete(individual).subscribe(
      (task: any) => {
        this.individuals.splice(this.individuals.indexOf(individual), 1);
        this.individuals = this.individuals.slice(0); // Force ag-grid to deal with change in rows
      }
    );
  }

  get context(): any {
    return {
      me: this.user,
      gridHolder: this
    };
  }

  finishedEditing(result: FinishedEditing): void {
    if (this.selection) {
      if (this.selection.added) {
        this.selection.added = false;
        this.individuals.push(this.selection);
        this.id_map[this.selection.id] = this.selection;
        this.gridOptions.api.setRowData(this.individuals);
      } else {
        if (this.selection.id === this.user.id) {
          this.user.team_id = this.selection.team_id; // Update since used for new users
        }
        this.gridOptions.api.refreshView();
      }
    }
    switch (result) {
      case FinishedEditing.AddAnother:
        this.setSelection('New');
        break;
      case FinishedEditing.Save:
      case FinishedEditing.Cancel:
        this.router.navigate(['people']);
        break;
    }
  }
}
