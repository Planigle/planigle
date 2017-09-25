import { Component, Input } from '@angular/core';
import { AgRendererComponent } from 'ag-grid-ng2/main';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { EditReasonBlockedComponent } from '../edit-reason-blocked/edit-reason-blocked.component';
import { Individual } from '../../models/individual';
import { Status } from '../../models/status';

@Component({
  selector: 'app-choose-status',
  templateUrl: './choose-status.component.html',
  styleUrls: ['./choose-status.component.css']
})
export class ChooseStatusComponent implements AgRendererComponent {
  @Input() model: any;
  @Input() statuses: Status[] = [];
  @Input() me: Individual = null;
  @Input() includeNoChange: boolean = false;

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
    this.statuses = this.gridHolder.project.statuses;
  }

  updateStatus(select): void {
    let newStatusId: number = parseInt(String(select.currentTarget.value), 10); // Angular is converting this to a string
    let newStatus: Status = this.findStatus(newStatusId);
    if (newStatus.status_code === 2 && this.gridHolder) {
      const modalRef: NgbModalRef = this.modalService.open(EditReasonBlockedComponent);
      let model: any = {
        reason_blocked: ''
      };
      modalRef.componentInstance.model = model;
      modalRef.result.then(
        (result: any) => {
          if (model.reason_blocked == null) {
            this.finishUpdateStatus(this.findStatus(this.model.status_id), this.model.reason_blocked);
          } else {
            this.finishUpdateStatus(newStatus, model.reason_blocked);
          }
        });
    } else {
      this.finishUpdateStatus(newStatus, '');
    }
  }

  private findStatus(status_id: number): Status {
    let candidate: Status = new Status({
      id: -1,
      status_code: -1
    });
    this.statuses.forEach((status: Status) => {
      if (status.id === status_id) {
        candidate = status;
      }
    });
    return candidate;
  }

  private finishUpdateStatus(newStatus: Status, reason_blocked): void {
    this.model.status_id = newStatus.id;
    this.model.status_code = newStatus.status_code;
    if (this.model.status_code !== 2 || this.gridHolder) {
      this.model.reason_blocked = reason_blocked;
    }
    let changeOwner: boolean =
      ('isStory' in this.model) && !this.model.isStory() &&
      (this.model.status_code === 1 || this.model.status_code === 3) &&
      this.model.individual_id === null;
    if (changeOwner) {
      // In Progress or completed
      this.model.individual_id = this.me.id;
      this.model.individual_name = this.me.name;
    }
    if (this.updateFunction) {
      this.updateFunction.call(this.gridHolder, this.model);
    }
  }
}
