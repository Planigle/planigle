import { Component, AfterViewInit, OnDestroy } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { GridOptions } from 'ag-grid/main';
import { SurveyExcludedComponent } from '../survey-excluded/survey-excluded.component';
import { SurveysService } from '../../services/surveys.service';
import { SessionsService } from '../../services/sessions.service';
import { Survey } from '../../models/survey';
import { Individual } from '../../models/individual';
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-surveys',
  templateUrl: './surveys.component.html',
  styleUrls: ['./surveys.component.css'],
  providers: [SurveysService]
})
export class SurveysComponent implements AfterViewInit, OnDestroy {
  static self: SurveysComponent;
  public gridOptions: GridOptions = <GridOptions>{};
  public detailsGridOptions: GridOptions = <GridOptions>{};
  public columnDefs: any[] = [{
    headerName: 'Name',
    width: 250,
    field: 'name'
  }, {
    headerName: 'Company',
    width: 250,
    field: 'company'
  }, {
    headerName: 'Email',
    width: 250,
    field: 'email'
  }, {
    headerName: 'Excluded',
    width: 80,
    field: 'excluded',
    cellRendererFramework: SurveyExcludedComponent,
  }, {
    headerName: 'Last Updated',
    width: 150,
    field: 'updatedString'
  }];
  public detailsColumnDefs: any[] = [{
    headerName: 'Name',
    width: 350,
    field: 'name'
  }, {
    headerName: 'Description',
    width: 600,
    field: 'description',
    tooltipField: 'description'
  }, {
    headerName: 'Rank',
    width: 80,
    field: 'normalized_priority'
  }, {
    headerName: 'User Rank',
    width: 80,
    field: 'priority'
  }];
  public surveys: Survey[] = null;
  public selection: Survey;
  public user: Individual;

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private sessionsService: SessionsService,
    private surveysService: SurveysService
  ) {}

  ngAfterViewInit(): void {
    SurveysComponent.self = this;
    this.setGridHeight();
    $(window).resize(this.setGridHeight);
    this.user = new Individual(this.sessionsService.getCurrentUser());
    this.route.params.subscribe((params: Map<string, string>) => this.applyNavigation(params));
  }

  ngOnDestroy(): void {
    $(window).off('resize');
  }

  getRowClass(rowItem: any): string {
    return 'id-' + rowItem.data.id + (SurveysComponent.self.selection === rowItem.data ? ' selected' : '');
  }

  private setGridHeight(): void {
    let height = ($(window).height() - $('app-header').height() - 15);
    $('app-surveys .surveys ag-grid-ng2').height(height * 0.4);
    $('app-surveys .mappings ag-grid-ng2').height(height * 0.6);
  }

  private fetchSurveys(afterAction, afterActionParams): void {
    this.surveysService.getSurveys()
      .subscribe(
        (surveys: Survey[]) => {
          this.surveys = surveys;
          if (afterAction) {
            afterAction.call(this, afterActionParams);
          }
        });
  }

  private applyNavigation(params: Map<string, string>): void {
    let surveyId: string = params['survey'];
    if (this.surveys) {
      this.setSelection(surveyId);
    } else {
      this.fetchSurveys(this.setSelection, surveyId);
    }
  }

  private setSelection(surveyId: string): void {
    $('.ag-row').removeClass('selected');
    if (surveyId) {
      $('.ag-row.id-' + surveyId).addClass('selected');
      this.surveys.forEach((survey: Survey) => {
        if (String(survey.id) === surveyId) {
          this.selection = survey;
          if (!survey.surveyMappings) {
            this.surveysService.getMappings(survey).subscribe(() => {});
          }
        }
      });
    } else {
      this.selection = null;
    }
  }

  get context(): any {
    return {
      me: this.user,
      gridHolder: this,
      updateFunction: this.excludedChanged
    };
  }

  excludedChanged(survey: Survey): void {
    this.surveysService.update(survey).subscribe((modifiedSurvey: Survey) => {});
    this.gridOptions.api.refreshView();
  }

  viewSurvey(event): void {
    this.router.navigate(['surveys', {survey: event.data.id}]);
  }
}
