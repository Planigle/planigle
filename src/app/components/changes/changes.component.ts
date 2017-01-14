import { Component, AfterViewInit, OnDestroy } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { GridOptions } from 'ag-grid/main';
import { HtmlCellComponent } from '../../components/html-cell/html-cell.component';
import { ChangesService } from '../../services/changes.service';
import { IndividualsService } from '../../services/individuals.service';
import { DatesService } from '../../services/dates.service';
import { Change } from '../../models/change';
import { Individual } from '../../models/individual';
declare var $: any;

@Component({
  selector: 'app-changes',
  templateUrl: './changes.component.html',
  styleUrls: ['./changes.component.css'],
  providers: [ChangesService, IndividualsService, DatesService]
})
export class ChangesComponent implements AfterViewInit, OnDestroy {
  public gridOptions: GridOptions = <GridOptions>{};
  public columnDefs: any[] = [{
    headerName: 'Date',
    width: 150,
    field: 'created_string'
  }, {
    headerName: 'User',
    width: 150,
    field: 'user_name'
  }, {
    headerName: 'Object Type',
    width: 100,
    field: 'auditable_type'
  }, {
    headerName: 'Object Name',
    width: 300,
    field: 'auditable_name'
  }, {
    headerName: 'Change Type',
    width: 100,
    field: 'action',
    tooltipField: 'action'
  }, {
    headerName: 'Change Details',
    width: 300,
    field: 'audited_changes',
    cellRendererFramework: HtmlCellComponent,
  }];
  public changes: Change[] = [];
  public individuals: Individual[] = [];
  public individual: any = 'null';
  public objectType: any = 'null';
  public start: Date;
  public end: Date;

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private changesService: ChangesService,
    private individualsService: IndividualsService,
    private datesService: DatesService
  ) {}

  ngAfterViewInit(): void {
    this.setGridHeight();
    $(window).resize(this.setGridHeight);
    this.route.params.subscribe((params: Map<string, string>) => this.applyNavigation(params));
    this.fetchUsers();
  }

  gridReady(): void {
    $('.html-cell').popover({
      trigger: 'hover',
      placement: 'left',
      html: true
    });
  }

  ngOnDestroy(): void {
    $(window).off('resize');
  }

  private setGridHeight(): void {
    $('ag-grid-ng2').height($(window).height() - $('app-header').height() - 40);
  }

  private applyNavigation(params: Map<string, string>): void {
    let user: number = params['user'] ? parseInt(params['user'], 10) : null;
    if (user) {
      this.individual = user;
    }
    let objectType: string = params['type'];
    if (objectType) {
      this.objectType = objectType;
    }
    this.start = this.datesService.parseDate(params['start']);
    this.end = this.datesService.parseDate(params['end']);
    this.fetchChanges(user, objectType, this.start, this.end, params['id']);
  }

  updateNavigation(): void {
    let params: Map<string, string> = new Map();
    if (this.individual !== 'null') {
      params['user'] = this.individual;
    }
    if (this.objectType !== 'null') {
      params['type'] = this.objectType;
    }
    if (this.start != null) {
      params['start'] = this.datesService.getDateStringYearFirst(this.start);
    }
    if (this.end != null) {
      params['end'] = this.datesService.getDateStringYearFirst(this.end);
    }
    this.router.navigate(['changes', params]);
  }

  updateStart(date: Date) {
    this.start = date;
    this.updateNavigation();
  }

  updateEnd(date: Date) {
    this.end = date;
    this.updateNavigation();
  }

  startStringTwoDigit(): String {
    return this.datesService.getDateStringTwoDigit(this.start);
  }

  endStringTwoDigit(): String {
    return this.datesService.getDateStringTwoDigit(this.end);
  }

  private fetchChanges(user_id: number, object_type: string, start: Date, end: Date, object_id: number): void {
    this.changesService.getChanges(user_id, object_type, start, end, object_id).subscribe(
      (changes: Change[]) => this.changes = changes);
  }

  private fetchUsers(): void {
    this.individualsService.getIndividuals().subscribe(
      (individuals: Individual[]) => this.individuals = individuals);
  }
}
