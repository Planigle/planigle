import { Component } from '@angular/core';
import { AgRendererComponent } from 'ag-grid-ng2/main';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { StoriesComponent } from '../stories/stories.component';
import { ConfirmationDialogComponent } from '../confirmation-dialog/confirmation-dialog.component';
import { Work } from '../../models/work';
import { Story } from '../../models/story';

@Component({
  selector: 'app-story-actions',
  templateUrl: './story-actions.component.html',
  styleUrls: ['./story-actions.component.css']
})
export class StoryActionsComponent implements AgRendererComponent {
  private model: Work;
  private grid: StoriesComponent;

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
    const modalRef: NgbModalRef = this.modalService.open(ConfirmationDialogComponent);
    let typeOfObject: string = this.model.isStory() ? 'Story' : 'Task';
    let component: ConfirmationDialogComponent = modalRef.componentInstance;
    component.confirmDelete(typeOfObject, this.model.name);
    modalRef.result.then(
      (result: any) => {
        if (component.model.confirmed) {
          self.grid.deleteWork(self.model);
        }
      }
    );
  }

  addChild(): void {
    this.grid.addChild(<Story> this.model);
  }
}
