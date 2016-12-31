import { Component } from '@angular/core';
import { AgRendererComponent } from 'ag-grid-ng2/main';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { ConfirmationDialogComponent } from '../confirmation-dialog/confirmation-dialog.component';
import { Task } from '../../models/task';
import { FinishedEditing } from '../../models/finished-editing';

@Component({
  selector: 'app-story-actions',
  templateUrl: './story-actions.component.html',
  styleUrls: ['./story-actions.component.css']
})
export class StoryActionsComponent implements AgRendererComponent {
  private model: any;
  private grid: any;

  constructor(
    private modalService: NgbModal) { }

  agInit(params: any): void {
    this.model = params.data;
    this.grid = params.context.gridHolder;
  }

  edit(): void {
    this.grid.updateNavigation(this.model.uniqueId);
  }

  deleteItem(): void {
    let self: StoryActionsComponent = this;
    const modalRef: NgbModalRef = this.modalService.open(ConfirmationDialogComponent, {size: 'sm'});
    let typeOfObject: string = this.model.isStory() ? 'Story' : 'Task';
    let model: any = {
      title: 'Delete ' + typeOfObject,
      body: 'Are you sure you want to delete this ' + typeOfObject + '?',
      confirmed: false
    };
    modalRef.componentInstance.model = model;
    modalRef.result.then(
      (result: any) => {
        if (model.confirmed) {
          self.grid.deleteWork(self.model);
        }
      }
    );
  }

  addTask(): void {
    this.grid.addTask(this.model);
  }
}
