import { Component } from '@angular/core';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';

@Component({
  selector: 'app-edit-reason-blocked',
  templateUrl: './edit-reason-blocked.component.html',
  styleUrls: ['./edit-reason-blocked.component.css']
})
export class EditReasonBlockedComponent {
  model: any;

  constructor(
    private activeModal: NgbActiveModal,
  ) { }

  ok(): void {
    this.activeModal.close('OK');
  }

  cancel(): void {
    this.model.reason_blocked = null;
    this.activeModal.close('Cancel');
  }
}
