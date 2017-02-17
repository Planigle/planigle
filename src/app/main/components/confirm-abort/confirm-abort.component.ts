import { Component, AfterViewInit } from '@angular/core';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
declare var $: any;

@Component({
  selector: 'app-confirm-abort',
  templateUrl: './confirm-abort.component.html',
  styleUrls: ['./confirm-abort.component.css']
})
export class ConfirmAbortComponent implements AfterViewInit {
  model: any = {
    response: null
  };

  constructor(
    private activeModal: NgbActiveModal,
  ) { }

  ngAfterViewInit(): void {
    $('input[autofocus]').focus();
  }

  yes(): void {
    this.model.response = 'Yes';
    this.activeModal.close('Yes');
  }

  no(): void {
    this.model.response = 'No';
    this.activeModal.close('No');
  }

  cancel(): void {
    this.model.response = null;
    this.activeModal.close('Cancel');
  }
}
