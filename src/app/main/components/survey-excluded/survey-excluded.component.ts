import { Component, Input } from '@angular/core';
import { AgRendererComponent } from 'ag-grid-ng2/main';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { EditReasonBlockedComponent } from '../edit-reason-blocked/edit-reason-blocked.component';
import { Individual } from '../../models/individual';

@Component({
  selector: 'app-survey-excluded',
  templateUrl: './survey-excluded.component.html',
  styleUrls: ['./survey-excluded.component.css']
})
export class SurveyExcludedComponent implements AgRendererComponent {
  @Input() model: any;
  @Input() me: Individual = null;

  private updateFunction: any;
  private gridHolder: any;

  constructor(
    private modalService: NgbModal
  ) { }

  agInit(params: any): void {
    this.model = params.data;
    this.me = params.context.me;
    this.updateFunction = params.context.updateFunction;
    this.gridHolder = params.context.gridHolder;
  }

  updateExcluded(event: any): void {
    this.model.excluded = event.currentTarget.value === 'true';
    this.updateFunction.call(this.gridHolder, this.model);
  }
}
