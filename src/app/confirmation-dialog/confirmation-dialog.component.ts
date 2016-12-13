import { Component } from '@angular/core';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';

@Component({
  selector: 'app-confirmation-dialog',
  templateUrl: './confirmation-dialog.component.html',
  styleUrls: ['./confirmation-dialog.component.css']
})
export class ConfirmationDialogComponent {
  model: any;

  constructor(
    private activeModal: NgbActiveModal,
  ) { }

  ok() {
    this.model.confirmed = true;
    this.activeModal.close('OK');
  }

  cancel() {
    this.model.confirmed = false;
    this.activeModal.close('Cancel');
  }
}
