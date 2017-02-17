import { Component, AfterViewInit } from '@angular/core';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
declare var $: any;

@Component({
  selector: 'app-confirmation-dialog',
  templateUrl: './confirmation-dialog.component.html',
  styleUrls: ['./confirmation-dialog.component.css']
})
export class ConfirmationDialogComponent implements AfterViewInit {
  model: any;

  constructor(
    private activeModal: NgbActiveModal,
  ) { }

  confirmDelete(objectType: string, objectName: string) {
    this.model = {
      title: 'Delete ' + objectType,
      body: 'Are you sure you want to delete "' + objectName + '"?',
      confirmed: false
    };
  }

  ngAfterViewInit(): void {
    $('input[autofocus]').focus();
  }

  ok(): void {
    this.model.confirmed = true;
    this.activeModal.close('OK');
  }

  cancel(): void {
    this.model.confirmed = false;
    this.activeModal.close('Cancel');
  }
}
