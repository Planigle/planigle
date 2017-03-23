import { Component, AfterViewInit, OnDestroy } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { GridOptions } from 'ag-grid/main';
import { SurveysService } from '../../services/surveys.service';
import { DragDropService } from '../../services/drag-drop.service';
import { ErrorService } from '../../services/error.service';
import { Survey } from '../../models/survey';
import { SurveyMapping } from '../../models/survey-mapping';
declare var $: any;

@Component({
  selector: 'app-survey',
  templateUrl: './survey.component.html',
  styleUrls: ['./survey.component.css'],
  providers: [ SurveysService, DragDropService ]
})
export class SurveyComponent implements AfterViewInit, OnDestroy {
  survey: Survey = new Survey({});
  error: string;
  notice: string;
  gridOptions: GridOptions = <GridOptions>{};
  submitted: boolean = false;
  suggestion: SurveyMapping;
  nextId: number = -1;
  columnDefs: any[] = [{
    headerName: 'Name',
    width: 350,
    field: 'name'
  }, {
    headerName: 'Description',
    width: 600,
    field: 'descriptionFirstLine',
    tooltipField: 'description'
  }];
  private id_map: Map<string, SurveyMapping> = new Map();

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private surveysService: SurveysService,
    private dragDropService: DragDropService,
    private errorService: ErrorService
  ) {}

  ngAfterViewInit(): void {
    this.setGridHeight();
    $(window).resize(this.setGridHeight);
    this.route.params.subscribe((params: Map<string, string>) => this.applyNavigation(params));
  }

  gridReady(): void {
    this.dragDropService.setUpDragDrop(this, this.dropRow);
  }

  dropRow(event, ui, target, copy: boolean): void {
    let movedRow: SurveyMapping = this.getRow($(ui.draggable[0]));
    let targetRow: SurveyMapping = this.getRow(target);
    this.dropMapping(movedRow, targetRow);
  }

  private dropMapping(mapping: SurveyMapping, targetMapping: SurveyMapping): void {
    let mappings = this.survey.surveyMappings;
    mappings.splice(mappings.indexOf(mapping), 1);
    if (targetMapping) {
      mappings.splice(mappings.indexOf(targetMapping), 0, mapping);
    } else {
      mappings.push(mapping);
    }
    this.gridOptions.api.setRowData(mappings);
  }

  getRowClass(rowItem: any): string {
    return 'id-' + rowItem.data.story_id;
  }

  private getRow(jQueryObject: any): SurveyMapping {
    let result: string = null;
    $.each(jQueryObject.attr('class').toString().split(' '), function (i: number, className: string) {
      if (className.indexOf('id-') === 0) {
        result = className.substring(3);
      }
    });
    return this.id_map[result];
  }

  private applyNavigation(params: Map<string, string>) {
    let surveyKey = params['survey_key'];
    if (surveyKey) {
      this.surveysService.getSurvey(surveyKey).subscribe(
        (survey: Survey) => {
          this.survey = survey;
          survey.surveyMappings.forEach((mapping: SurveyMapping) => {
            this.id_map[mapping.story_id] = mapping;
          });
        },
        (error) => {
          this.error = this.errorService.getError(error);
        });
    } else {
      this.error = 'Invalid URL.  Must include survey key.';
    }
  }

  ngOnDestroy(): void {
    $(window).off('resize');
  }

  private setGridHeight(): void {
    $('ag-grid-ng2').height($(window).height() - 325);
  }

  addSuggestion(): void {
    this.suggestion = new SurveyMapping({});
  }

  finishedSuggesting(shouldAdd: boolean): void {
    if (shouldAdd)  {
      this.survey.surveyMappings.push(this.suggestion);
      this.suggestion.story_id = this.nextId;
      this.id_map[this.nextId] = this.suggestion;
      this.nextId--;
      this.gridOptions.api.setRowData(this.survey.surveyMappings);
    }
    this.suggestion = null;
  }

  submit(): void {
    this.submitted = true;
    this.error = null;
    this.notice = null;
    this.surveysService.submit(this.survey).subscribe(
      (message: string) => {
        this.notice = message;
      }, (error) => {
        this.submitted = false;
        this.error = this.errorService.getError(error);
      });
  }
}
