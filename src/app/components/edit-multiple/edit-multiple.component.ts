import { Component } from '@angular/core';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { StoriesComponent } from '../stories/stories.component.js';
import { StoriesService } from '../../services/stories.service';
import { TasksService } from '../../services/tasks.service';
import { ErrorService } from '../../services/error.service';
import { Work } from '../../models/work';
import { Story } from '../../models/story';
import { Task } from '../../models/task';
import { Release } from '../../models/release';
import { Iteration } from '../../models/iteration';
import { Team } from '../../models/team';
import { Individual } from '../../models/individual';
import { StoryAttribute } from '../../models/story-attribute';
import { StoryValue } from '../../models/story-value';

@Component({
  selector: 'app-edit-multiple',
  templateUrl: './edit-multiple.component.html',
  styleUrls: ['./edit-multiple.component.css'],
  providers: [StoriesService, TasksService, ErrorService]
})
export class EditMultipleComponent {
  public static NoChange = -1;
  public customStoryAttributes: StoryAttribute[];
  public grid: StoriesComponent;
  public model: any = {
    project_id: EditMultipleComponent.NoChange,
    release_id: EditMultipleComponent.NoChange,
    iteration_id: EditMultipleComponent.NoChange,
    team_id: EditMultipleComponent.NoChange,
    individual_id: EditMultipleComponent.NoChange,
    status_code: EditMultipleComponent.NoChange
  };
  public customValues: Map<string, any> = new Map();
  public selectedWork: Work[] = [];
  public releases: Release[] = [];
  public iterations: Iteration[] = [];
  public teams: Team[] = [];
  public individuals: Individual[] = [];

  constructor(
    private activeModal: NgbActiveModal,
    private storiesService: StoriesService,
    private tasksService: TasksService,
    private errorService: ErrorService
  ) {}

  setCustomStoryAttributes(attributes: StoryAttribute[]): void {
    this.customStoryAttributes = attributes;
    this.customStoryAttributes.forEach((storyAttribute: StoryAttribute) => {
      this.customValues[storyAttribute.id] = EditMultipleComponent.NoChange;
    });
  }

  update(idParam: string): void {
    if (String(this.model[idParam]) === 'null') {
      this.model[idParam] = null;
    } else {
      this.model[idParam] = parseInt(String(this.model[idParam]), 10);
    }
  }

  onlyTasks(): boolean {
    let result = true;
    this.selectedWork.forEach((work: Work) => {
      if (work.isStory()) {
        result = false;
      }
    });
    return result;
  }

  ok(): void {
    let self: EditMultipleComponent = this;
    this.selectedWork.forEach((work: Work) => {
      if (work.isStory()) {
        self.updateStory(<Story>work);
      } else {
        self.updateTask(<Task>work);
      }
    });
    this.activeModal.close('OK');
  }

  private updateStory(work: Story): void {
    let hasChange = false;
    let record = {
      id: work.id
    };
    if (this.model.release_id !== EditMultipleComponent.NoChange) {
      record['release_id'] = this.model.release_id;
      record['release_name'] = null;
      hasChange = true;
    }
    if (this.model.iteration_id !== EditMultipleComponent.NoChange) {
      record['iteration_id'] = this.model.iteration_id;
      record['iteration_name'] = null;
      hasChange = true;
    }
    if (this.model.team_id !== EditMultipleComponent.NoChange) {
      record['team_id'] = this.model.team_id;
      record['team_name'] = null;
      hasChange = true;
    }
    if (this.model.individual_id !== EditMultipleComponent.NoChange) {
      record['individual_id'] = this.model.individual_id;
      record['individual_name'] = null;
      hasChange = true;
    }
    if (this.model.status_code !== EditMultipleComponent.NoChange) {
      record['status_code'] = this.model.status_code;
      if (this.model.status_code === 2) {
        record['reason_blocked'] = null;
      }
      hasChange = true;
    }
    record['story_values'] = [];
    Object.keys(this.customValues).forEach((key) => {
      let value: any = this.customValues[key];
      if (value !== EditMultipleComponent.NoChange) {
        record['story_values'].push(new StoryValue({
          story_attribute_id: key,
          value: value === 'null' ? '' : value
        }));
        hasChange = true;
      }
    });
    if (hasChange) {
      let self: EditMultipleComponent = this;
      this.storiesService.update(record).subscribe(
        (story: Story) => {
          for (let property in record) {
            if (record.hasOwnProperty(property)) {
              work[property] = story[property];
            }
          }
          self.grid.updateGridForStatusChange(work);
        },
        (err: any) => this.errorService.showError(err)
      );
    }
  }

  private updateTask(work: Task): void {
    let hasChange = false;
    let record = {
      id: work.id,
      story_id: work.story_id
    };
    if (this.model.individual_id !== EditMultipleComponent.NoChange) {
      record['individual_id'] = this.model.individual_id;
      record['individual_name'] = null;
      hasChange = true;
    }
    if (this.model.status_code !== EditMultipleComponent.NoChange) {
      record['status_code'] = this.model.status_code;
      if (this.model.status_code === 2) {
        record['reason_blocked'] = this.model.reason_blocked;
      } else if ((this.model.status_code === 1 || this.model.status_code === 3) && work.individual_id === null) {
        record['individual_id'] = this.grid.user.id;
        record['individual_name'] = null;
      }
      hasChange = true;
    }
    if (hasChange) {
      let self: EditMultipleComponent = this;
      this.tasksService.update(record).subscribe(
        (task: Task) => {
          for (let property in record) {
            if (record.hasOwnProperty(property)) {
              work[property] = task[property];
            }
          }
          self.grid.updateGridForStatusChange(work);
        },
        (err: any) => this.errorService.showError(err)
      );
    }
  }

  cancel(): void {
    this.activeModal.close('Cancel');
  }
}
