import { Component, AfterViewInit } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { GridOptions } from 'ag-grid/main';
import { IndividualActionsComponent } from '../individual-actions/individual-actions.component';
import { IndividualsService } from '../../services/individuals.service';
import { CompaniesService } from '../../services/companies.service';
import { SessionsService } from '../../services/sessions.service';
import { Individual } from '../../models/individual';
import { Company } from '../../models/company';
import { Team } from '../../models/team';
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-individuals',
  templateUrl: './individuals.component.html',
  styleUrls: ['./individuals.component.css'],
  providers: [IndividualsService, CompaniesService]
})
export class IndividualsComponent implements AfterViewInit {
  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private sessionsService: SessionsService,
    private individualsService: IndividualsService,
    private companiesService: CompaniesService
  ) { }

  public gridOptions: GridOptions = <GridOptions>{};
  public columnDefs: any[] = [{
    headerName: '',
    width: 36,
    field: 'blank',
    cellRendererFramework: IndividualActionsComponent,
    suppressMovable: true,
    suppressResize: true,
    suppressSorting: true
  }, {
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
    width: 100,
    field: 'role_name'
  }, {
    headerName: 'Activated',
    width: 60,
    field: 'is_activated'
  }, {
    headerName: 'Enabled',
    width: 60,
    field: 'enabled'
  }, {
    headerName: 'Last Logged In',
    width: 150,
    field: 'last_login_string'
  }];
  public individuals: Individual[] = null;
  public teams: Team[] = [];
  public selection: Individual;
  public user: Individual;
 
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
    $('app-individuals ag-grid-ng2').height(($(window).height() - $('app-header').height() - 65) * 0.6);
  }
  
  private fetchIndividuals(afterAction, afterActionParams): void {
    this.individualsService.getIndividuals()
      .subscribe(
        (individuals: Individual[]) => {
          this.individuals = individuals;
          if(afterAction) {
            afterAction.call(this, afterActionParams);
          }
        });
  }
      
  private fetchCompany(): void {
    let self: IndividualsComponent = this;
    this.companiesService.getCompanies()
      .subscribe(
        (companies: Company[]) => {
          companies.forEach((company: Company) => { // only 1 company
            self.teams = company.getAllTeams();
          });
        });
  }
    
  private applyNavigation(params: Map<string,string>): void {
    let individualId: string = params['individual'];
    if(this.individuals) {
      this.setSelection(individualId);
    } else {
      this.fetchIndividuals(this.setSelection, individualId);
      this.fetchCompany();
    }
  }
  
  private setSelection(individualId: string): void {
    if(individualId) {
      if(individualId === 'New') {
        let lastIndividual = this.individuals.length > 0 ? this.individuals[this.individuals.length - 1] : null;
        this.selection = new Individual({
          role: 2,
          enabled: true,
          refresh_interval: 1000*60*5
        });
      } else {
        this.individuals.forEach((individual: Individual) => {
          if(String(individual.id) === individualId) {
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
  
  private editRow(event): void {
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
        this.gridOptions.api.setRowData(this.individuals);
      } else {
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
