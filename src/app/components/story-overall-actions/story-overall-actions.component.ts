import { Component, OnInit, Input } from '@angular/core';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { ConfirmationDialogComponent } from '../confirmation-dialog/confirmation-dialog.component';
import { StoriesComponent } from '../stories/stories.component';
import { StoryFiltersComponent } from '../story-filters/story-filters.component';
import { SelectColumnsComponent } from '../select-columns/select-columns.component';
import { EditMultipleComponent } from '../edit-multiple/edit-multiple.component';
import { StoriesService } from '../../services/stories.service';
import { ErrorService } from '../../services/error.service';
import { Work } from '../../models/work';
import { Story } from '../../models/story';
import { Task } from '../../models/task';
declare var $: any;

@Component({
  selector: 'app-story-overall-actions',
  templateUrl: './story-overall-actions.component.html',
  styleUrls: ['./story-overall-actions.component.css'],
  providers: [SelectColumnsComponent, NgbModal, StoriesService, ErrorService]
})
export class StoryOverallActionsComponent implements OnInit {
  @Input() grid: StoriesComponent;

  constructor(
    private storiesService: StoriesService,
    private errorService: ErrorService,
    private modalService: NgbModal) { }

  ngOnInit(): void {
    $('#import').fileupload(this.getFileUploadOptions());
  }

  export(): void {
    let filters: StoryFiltersComponent = this.grid.filters;
    this.storiesService.exportStories(filters.queryString);
  }

  import(): void {
    $('#import').click();
  }

  selectColumns(): void {
    const modalRef: NgbModalRef = this.modalService.open(SelectColumnsComponent, {size: 'sm'});
    modalRef.componentInstance.storyAttributes = this.grid.storyAttributes;
    modalRef.result.then((data) => this.grid.setAttributes(this.grid.storyAttributes));
  }

  refresh(): void {
    this.grid.refresh();
  }

  addStory(): void {
    this.grid.addStory();
  }

  editItems(): void {
    if (this.grid.selectedWork.length === 1) {
      this.grid.updateNavigation(this.grid.selectedWork[0].uniqueId);
    } else {
      const modalRef: NgbModalRef = this.modalService.open(EditMultipleComponent);
      let component: EditMultipleComponent = modalRef.componentInstance;
      component.grid = this.grid;
      component.setCustomStoryAttributes(this.grid.customStoryAttributes);
      component.selectedWork = this.grid.selectedWork;
      component.releases = this.grid.filters.choosableReleases;
      component.iterations = this.grid.filters.choosableIterations;
      component.teams = this.grid.filters.choosableTeams;
      component.individuals = this.grid.filters.choosableIndividuals;
    }
  }

  deleteItems(): void {
    let self: StoryOverallActionsComponent = this;
    const modalRef: NgbModalRef = this.modalService.open(ConfirmationDialogComponent, {size: 'sm'});
    let typeOfObject: string = this.grid.selectedWork.length === 1 ?
      (this.grid.selectedWork[0].isStory() ? 'Story' : 'Task') :
      'Items';
    let model: any = {
      title: 'Delete ' + typeOfObject,
      body: 'Are you sure you want to delete ' + (this.grid.selectedWork.length === 1 ? 'this ' : 'these ') + typeOfObject + '?',
      confirmed: false
    };
    modalRef.componentInstance.model = model;
    modalRef.result.then(
      (result: any) => {
        if (model.confirmed) {
          let stories: Story[] = [];
          let tasks: Task[] = [];
          this.grid.selectedWork.forEach((work: Work) => {
            if (work.isStory()) {
              stories.push(<Story>work);
              self.grid.deleteWork(work);
            } else {
              tasks.push(<Task>work);
            }
          });
          tasks.forEach((task: Task) => {
            if (stories.indexOf(task.story) === -1) {
              self.grid.deleteWork(task);
            }
          });
        }
      }
    );
  }

  hasItemsSelected(): boolean {
    return this.grid.selectedWork.length > 0;
  }

  private getFileUploadOptions(): any {
    let self: StoryOverallActionsComponent = this;
    let grid: StoriesComponent = this.grid;
    return {
      add: function(e, data) {
        grid.waiting = true;
        data.submit();
      },
      done: function(e, data) {
        grid.fetchStories();
        grid.waiting = false;
      },
      fail: function (e, data) {
        grid.waiting = false;
        self.errorService.showError(data.jqXHR.responseJSON.error);
      }
    };
  }
}
