import { Component } from '@angular/core';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';

@Component({
  selector: 'app-reason-blocked',
  templateUrl: './reason-blocked.component.html',
  styleUrls: ['./reason-blocked.component.css']
})
export class ReasonBlockedComponent {
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
