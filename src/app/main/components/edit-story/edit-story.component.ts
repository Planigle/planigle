import { Component, OnChanges, Input, Output, EventEmitter } from '@angular/core';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { Router } from '@angular/router';
import { ConfirmAbortComponent } from '../confirm-abort/confirm-abort.component';
import { EditAttributesComponent } from '../edit-attributes/edit-attributes.component';
import { AcceptanceCriteriaComponent } from '../acceptance-criteria/acceptance-criteria.component';
import { StoriesService } from '../../services/stories.service';
import { ErrorService } from '../../services/error.service';
import { Story } from '../../models/story';
import { Task } from '../../models/task';
import { StoryAttribute } from '../../models/story-attribute';
import { StoryValue } from '../../models/story-value';
import { Project } from '../../models/project';
import { Release } from '../../models/release';
import { Iteration } from '../../models/iteration';
import { Team } from '../../models/team';
import { AcceptanceCriterium } from '../../models/acceptance-criterium';
import { Individual } from '../../models/individual';
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-edit-story',
  templateUrl: './edit-story.component.html',
  styleUrls: ['./edit-story.component.css'],
  providers: [NgbModal, StoriesService, ErrorService]
})
export class EditStoryComponent implements OnChanges {
  @Input() story: Story;
  @Input() customStoryAttributes: StoryAttribute[];
  @Input() projects: Project[];
  @Input() epics: Story[];
  @Input() releases: Release[];
  @Input() iterations: Iteration[];
  @Input() teams: Team[];
  @Input() individuals: Individual[];
  @Input() me: Individual;
  @Input() hasPrevious: boolean;
  @Input() hasNext: boolean;
  @Input() split: boolean;
  @Input() showPublic: boolean;
  @Output() updatedAttributes: EventEmitter<any> = new EventEmitter();
  @Output() closed: EventEmitter<any> = new EventEmitter();

  public model: Story;
  public customValues: Map<string, any> = new Map();
  public customNumericValues: Map<string, number> = new Map();
  public error: String;
  private modelUpdated: boolean = false;

  constructor(
    private router: Router,
    private modalService: NgbModal,
    private storiesService: StoriesService,
    private errorService: ErrorService) {
  }

  ngOnChanges(changes: any) {
    if (changes.story) {
      this.modelUpdated = false;
      this.model = new Story(this.story);
      this.customValues = new Map();
      this.customNumericValues = new Map();
      this.setInitialValues();
      this.model.story_values.forEach((storyValue) => {
        this.customValues[storyValue.story_attribute_id] = storyValue.value;
        this.customNumericValues[storyValue.story_attribute_id] = parseFloat(storyValue.value);
      });
      setTimeout(() => $('input[autofocus=""]').focus(), 0);
    }
    if (changes.customStoryAttributes) {
      this.setInitialValues();
    }
    if ((changes.story || changes.split) && (this.model && this.split)) {
      let criteria: AcceptanceCriterium[] = [];
      this.model.acceptance_criteria.forEach((criterium: AcceptanceCriterium) => {
        if (!criterium.isDone()) {
          criteria.push(criterium);
        }
      });
      this.model.acceptance_criteria = criteria;
    }
    if ((changes.story || changes.split || changes.iterations) && (this.model && this.split && this.iterations.length > 0)
      && !this.modelUpdated) {
      this.modelUpdated = true;
      let selectedIndex = -1;
      let index = 0;
      this.iterations.forEach((iteration: Iteration) => {
        if (iteration.id === this.model.iteration_id) {
          selectedIndex = index;
        }
        index++;
      });
      if (selectedIndex !== -1 && selectedIndex < this.iterations.length - 1) {
        this.model.iteration_id = this.iterations[selectedIndex + 1].id;
      } else {
        this.model.iteration_id = null;
      }
    }
  }

  private setInitialValues(): void {
    this.customStoryAttributes.forEach((storyAttribute: StoryAttribute) => {
      if (!this.customValues[storyAttribute.id]) {
        this.customValues[storyAttribute.id] = storyAttribute.hasList() ? 'null' : null;
        this.customNumericValues[storyAttribute.id] = null;
      }
    });
  }

  isNew(): boolean {
    return this.model.id == null;
  }

  updateProject(): void {
    let storyId: number = parseInt(String(this.model.project_id), 10);
    this.model.project_id = storyId;
    this.model.release_id = null;
    this.model.release_name = null;
    this.model.iteration_id = null;
    this.model.iteration_name = null;
    this.model.team_id = null;
    this.model.team_name = null;
    let hasOwner = false;
    this.individuals.forEach((individual: Individual) => {
      if (individual.id === this.model.individual_id) {
        for (let i = 0; i < individual.project_ids.length; i++) {
          if (individual.project_ids[i] === storyId) {
            hasOwner = true;
          }
        }
      }
    });
    if (!hasOwner) {
      this.model.individual_id = null;
      this.model.individual_name = null;
    }
  }

  updateEpic(): void {
    if (String(this.model.story_id) === 'null') {
      this.model.story_id = null;
    } else {
      this.model.story_id = parseInt(String(this.model.story_id), 10);
    }
  }

  updateRelease(): void {
    if (String(this.model.release_id) === 'null') {
      this.model.release_id = null;
      this.model.release_name = null;
    } else {
      let storyId: number = parseInt(String(this.model.release_id), 10);
      this.model.release_id = storyId;
      this.releases.forEach((release: any) => {
        if (release.id === storyId) {
          this.model.release_name = release.name;
        };
      });
    }
  }

  updateIteration(): void {
    if (String(this.model.iteration_id) === 'null') {
      this.model.iteration_id = null;
      this.model.iteration_name = null;
    } else {
      let storyId: number = parseInt(String(this.model.iteration_id), 10);
      this.model.iteration_id = storyId;
      this.iterations.forEach((iteration: any) => {
        if (iteration.id === storyId) {
          this.model.iteration_name = iteration.name;
        };
      });
    }
  }

  updateTeam(): void {
    if (String(this.model.team_id) === 'null') {
      this.model.team_id = null;
      this.model.team_name = null;
    } else {
      let storyId: number = parseInt(String(this.model.team_id), 10);
      this.model.team_id = storyId;
      this.teams.forEach((team: any) => {
        if (team.id === storyId) {
          this.model.team_name = team.name;
        };
      });
    }
  }

  updateOwner(): void {
    if (String(this.model.individual_id) === 'null') {
      this.model.individual_id = null;
      this.model.individual_name = null;
    } else {
      let storyId: number = parseInt(String(this.model.individual_id), 10);
      this.model.individual_id = storyId;
      this.individuals.forEach((individual: any) => {
        if (individual.id === storyId) {
          this.model.individual_name = individual.name;
        };
      });
    }
  }

  canSave(form: any): boolean {
    return this.formValid(form) && this.me.canChangeBacklog();
  }

  formValid(form: any): boolean {
    return form.form.valid || !this.me.canChangeBacklog();
  }

  ok(): void {
    this.saveModel(FinishedEditing.Save, null);
  }

  next(): void {
    this.saveModel(FinishedEditing.Next, null);
  }

  previous(): void {
    this.saveModel(FinishedEditing.Previous, null);
  }

  addAnother(form: any): void {
    this.saveModel(FinishedEditing.AddAnother, form);
  }

  cancel(): void {
    this.closed.emit({value: FinishedEditing.Cancel});
  }

  private saveModel(result: FinishedEditing, form: any): void {
    if (this.split) {
      let self: EditStoryComponent = this;
      const modalRef: NgbModalRef = this.modalService.open(ConfirmAbortComponent);
      let component: ConfirmAbortComponent = modalRef.componentInstance;
      modalRef.result.then(
        (answer: any) => {
          if (component.model.response) {
            if (component.model.response === 'Yes') {
              this.story.status_code = 3;
              this.story.effort = 0;
              this.storiesService.update(this.story).subscribe((modifiedStory: Story) => {
                self.updateModel(result, form);
              });
            } else {
              self.updateModel(result, form);
            }
          }
        }
      );
    } else {
      this.updateModel(result, form);
    }
  }

  private updateModel(result: FinishedEditing, form: any): void {
    if (this.me.canChangeBacklog()) {
      let self: EditStoryComponent = this;
      this.model.story_values = [];
      this.customStoryAttributes.forEach((storyAttribute: StoryAttribute) => {
        let key: string = storyAttribute.id + '';
        let value: any = storyAttribute.isNumber() ? self.customNumericValues[key] : self.customValues[key];
        this.model.story_values.push(new StoryValue({
          story_attribute_id: storyAttribute.id,
          value: value === 'null' ? '' : value
        }));
      });
      if (this.model.acceptance_criteria.length === 1 &&
        this.model.acceptance_criteria[0].description === AcceptanceCriteriaComponent.instructions) {
        this.model.acceptance_criteria = [];
      }
      let method: any = this.model.id ?
        (this.split ? this.storiesService.split : this.storiesService.update) :
        this.storiesService.create;
      method.call(this.storiesService, this.model).subscribe(
        (story: Story) => {
          if (this.split) {
            let newTasks = [];
            this.story.tasks.forEach((task: Task) => {
              if (task.status_code === 3) {
                newTasks.push(task);
              }
            });
            this.story.tasks = newTasks;
            let newCriteria = [];
            this.story.acceptance_criteria.forEach((criterium: AcceptanceCriterium) => {
              if (criterium.isDone()) {
                newCriteria.push(criterium);
              }
            });
            this.story.acceptance_criteria = newCriteria;
            this.story.split = story;
          } else {
            if (!this.story.id) {
              this.story.added = true;
            }
            this.story.id = story.id;
            this.story.story_id = story.story_id;
            this.story.epic_name = story.epic_name;
            this.story.name = story.name;
            this.story.description = story.description;
            this.story.status_code = story.status_code;
            this.story.acceptance_criteria = story.acceptance_criteria;
            this.story.reason_blocked = story.reason_blocked;
            this.story.project_id = story.project_id;
            this.story.release_id = story.release_id;
            this.story.release_name = story.release_name;
            this.story.iteration_id = story.iteration_id;
            this.story.iteration_name = story.iteration_name;
            this.story.team_id = story.team_id;
            this.story.team_name = story.team_name;
            this.story.individual_id = story.individual_id;
            this.story.individual_name = story.individual_name;
            this.story.effort = story.effort;
            this.story.priority = story.priority;
            this.story.user_priority = story.user_priority;
            this.story.story_values = story.story_values;
            this.story.is_public = story.is_public;
          }
          if (form) {
            form.reset();
            $('input[name="name"]').focus();
          }
          this.closed.emit({value: result});
        },
        (err: any) => {
          this.error = this.errorService.getError(err);
        }
      );
    } else {
      this.closed.emit({value: result});
    }
  }

  editAttributes(): void {
    const modalRef: NgbModalRef = this.modalService.open(EditAttributesComponent);
    let component: EditAttributesComponent = modalRef.componentInstance;
    component.setReleases(this.releases);
    component.setCustomStoryAttributes(this.customStoryAttributes);
    modalRef.result.then(
      (data) => {
        if (component.hasChanges) {
          this.updatedAttributes.next();
        }
      });
  }

  viewChanges(): void {
    this.router.navigate(['changes', {type: 'Story', id: this.model.id}]);
  }
}
