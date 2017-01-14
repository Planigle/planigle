import { Component } from '@angular/core';
import { AgRendererComponent } from 'ag-grid-ng2/main';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { IndividualsComponent } from '../individuals/individuals.component';
import { ConfirmationDialogComponent } from '../confirmation-dialog/confirmation-dialog.component';
import { Individual } from '../../models/individual';

@Component({
  selector: 'app-individual-actions',
  templateUrl: './individual-actions.component.html',
  styleUrls: ['./individual-actions.component.css']
})
export class IndividualActionsComponent implements AgRendererComponent {
  model: Individual;
  grid: IndividualsComponent;

  constructor(
      private modalService: NgbModal,
  ) { }

  agInit(params: any): void {
    this.model = params.data;
    this.grid = params.context.gridHolder;
  }

  edit(): void {
    this.grid.editIndividual(this.model);
  }

  deleteItem(): void {
    let self: IndividualActionsComponent = this;
    const modalRef: NgbModalRef = this.modalService.open(ConfirmationDialogComponent);
    let component: ConfirmationDialogComponent = modalRef.componentInstance;
    component.confirmDelete('Iteration', this.model.name);
    modalRef.result.then(
      (result: any) => {
        if (component.model.confirmed) {
          self.grid.deleteIndividual(self.model);
        }
      }
    );
  }
}
