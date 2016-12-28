import { Component, Input } from '@angular/core';
import { AgRendererComponent } from 'ag-grid-ng2/main';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { EditReasonBlockedComponent } from '../edit-reason-blocked/edit-reason-blocked.component';
import { Individual } from '../../models/individual';

@Component({
  selector: 'app-choose-status',
  templateUrl: './choose-status.component.html',
  styleUrls: ['./choose-status.component.css']
})
export class ChooseStatusComponent implements AgRendererComponent {
  @Input() model: any;
  @Input() me: Individual;

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

  updateStatus(newStatus): void {
    let newValue: number = parseInt(String(newStatus.currentTarget.value), 10); // Angular is converting this to a string
    if (newValue === 2 && this.gridHolder) {
      const modalRef: NgbModalRef = this.modalService.open(EditReasonBlockedComponent);
      let model: any = {
        reason_blocked: ''
      };
      modalRef.componentInstance.model = model;
      modalRef.result.then(
        (result: any) => {
          if (model.reason_blocked == null) {
            this.finishUpdateStatus(this.model.status_code, this.model.reason_blocked);
          } else {
            this.finishUpdateStatus(newValue, model.reason_blocked);
          }
        });
    } else {
      this.finishUpdateStatus(newValue, '');
    }
  }

  private finishUpdateStatus(newValue, reason_blocked): void {
    this.model.status_code = newValue;
    if (newValue !== 2 || this.gridHolder) {
      this.model.reason_blocked = reason_blocked;
    }
    let changeOwner: boolean =
      !this.model.isStory() &&
      (this.model.status_code === 1 || this.model.status_code === 3) &&
      this.model.individual_id === null;
    if (changeOwner) {
      // In Progress or completed
      this.model.individual_id = this.me.id;
      this.model.individual_name = this.me.name;
    }
    if (this.updateFunction) {
      this.updateFunction(this.gridHolder, this.model);
    }
  }
}
