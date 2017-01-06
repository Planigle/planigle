import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { AgRendererComponent } from 'ag-grid-ng2/main';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { ReleasesComponent } from '../releases/releases.component';
import { ConfirmationDialogComponent } from '../confirmation-dialog/confirmation-dialog.component';
import { Release } from '../../models/release';

@Component({
  selector: 'app-release-actions',
  templateUrl: './release-actions.component.html',
  styleUrls: ['./release-actions.component.css']
})
export class ReleaseActionsComponent implements AgRendererComponent {
  model: Release;
  grid: ReleasesComponent;
  
  constructor(
    private modalService: NgbModal,
    private router: Router,
  ) { }
  
  agInit(params: any): void {
    this.model = params.data;
    this.grid = params.context.gridHolder;
  }
  
  edit(): void {
    this.grid.editRelease(this.model);
  }
  
  deleteItem(): void {
    let self: ReleaseActionsComponent = this;
    const modalRef: NgbModalRef = this.modalService.open(ConfirmationDialogComponent);
    let component: ConfirmationDialogComponent = modalRef.componentInstance;
    component.confirmDelete('Release', this.model.name);
    modalRef.result.then(
      (result: any) => {
        if (component.model.confirmed) {
          self.grid.deleteRelease(self.model);
        }
      }
    );
  }
  
  plan(): void {
      this.router.navigate(['stories', {release: this.model.id}]);
  }
}
