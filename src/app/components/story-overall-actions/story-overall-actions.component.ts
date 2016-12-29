import { Component, OnInit, Input } from '@angular/core';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { StoriesComponent } from '../stories/stories.component';
import { StoryFiltersComponent } from '../story-filters/story-filters.component';
import { SelectColumnsComponent } from '../select-columns/select-columns.component';
import { StoriesService } from '../../services/stories.service';
import { ErrorService } from '../../services/error.service';
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
  
  export() {
    let filters: StoryFiltersComponent = this.grid.filters;
    this.storiesService.exportStories(filters.queryString);
  }

  import() {
    $('#import').click();
  }
  
  selectColumns(): void {
    const modalRef: NgbModalRef = this.modalService.open(SelectColumnsComponent, {size: 'sm'});
    modalRef.componentInstance.storyAttributes = this.grid.storyAttributes;
    modalRef.result.then((data) => this.grid.setAttributes(this.grid.storyAttributes));
  }

  refresh() {
    this.grid.refresh();
  }
  
  addStory() {
    this.grid.addStory();
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
