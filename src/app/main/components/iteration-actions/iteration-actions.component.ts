import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { AgRendererComponent } from 'ag-grid-ng2/main';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { IterationsComponent } from '../iterations/iterations.component';
import { ConfirmationDialogComponent } from '../confirmation-dialog/confirmation-dialog.component';
import { Iteration } from '../../models/iteration';

@Component({
  selector: 'app-iteration-actions',
  templateUrl: './iteration-actions.component.html',
  styleUrls: ['./iteration-actions.component.css']
})
export class IterationActionsComponent implements AgRendererComponent {
  model: Iteration;
  grid: IterationsComponent;

  constructor(
    private modalService: NgbModal,
    private router: Router,
  ) { }

  agInit(params: any): void {
    this.model = params.data;
    this.grid = params.context.gridHolder;
  }

  edit(): void {
      this.grid.editIteration(this.model);
  }

  deleteItem(): void {
    let self: IterationActionsComponent = this;
    const modalRef: NgbModalRef = this.modalService.open(ConfirmationDialogComponent);
    let component: ConfirmationDialogComponent = modalRef.componentInstance;
    component.confirmDelete('Iteration', this.model.name);
    modalRef.result.then(
      (result: any) => {
        if (component.model.confirmed) {
          self.grid.deleteIteration(self.model);
        }
      }
    );
  }

  plan(): void {
    this.router.navigate(['stories', {iteration: this.model.id}]);
  }
}
