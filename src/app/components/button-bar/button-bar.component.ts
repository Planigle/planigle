import { Component } from '@angular/core';
import { AgRendererComponent } from 'ag-grid-ng2/main';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { ConfirmationDialogComponent } from '../confirmation-dialog/confirmation-dialog.component';
import { StoriesService } from '../../services/stories.service';
import { TasksService } from '../../services/tasks.service';
import { Task } from '../../models/task';

@Component({
  selector: 'app-button-bar',
  templateUrl: './button-bar.component.html',
  styleUrls: ['./button-bar.component.css'],
  providers: [StoriesService, TasksService]
})
export class ButtonBarComponent implements AgRendererComponent {
  private model: any;
  private gridHolder: any;

  constructor(
    private modalService: NgbModal,
    private storiesService: StoriesService,
    private tasksService: TasksService) { }

  agInit(params: any): void {
    this.model = params.data;
    this.gridHolder = params.context.gridHolder;
  }

  edit(): void {
    this.gridHolder.selection = this.model;
  }

  deleteItem(): void {
    let self: ButtonBarComponent = this;
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
          let service: any = self.model.isStory() ? self.storiesService : self.tasksService;
          service.delete.call(service, self.model).subscribe(
            (task: any) => {
              self.gridHolder.selection = self.model;
              self.gridHolder.selection.deleted = true;
              self.gridHolder.clearSelection();
            }
          );
        }
      }
    );
  }

  addTask(): void {
    let task: Task = new Task({
      story_id: this.model.id,
      status_code: 0,
      individual_id: null
    });
    this.gridHolder.selection = task;
  }
}
