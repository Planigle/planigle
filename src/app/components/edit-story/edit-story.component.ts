import { Component, OnChanges, Input, Output, EventEmitter } from '@angular/core';
import { StoriesService } from '../../services/stories.service';
import { ErrorService } from '../../services/error.service';
import { Story } from '../../models/story';
import { StoryAttribute } from '../../models/story-attribute';
import { StoryValue } from '../../models/story-value';
import { Project } from '../../models/project';
import { Release } from '../../models/release';
import { Iteration } from '../../models/iteration';
import { Team } from '../../models/team';
import { Individual } from '../../models/individual';
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-edit-story',
  templateUrl: './edit-story.component.html',
  styleUrls: ['./edit-story.component.css'],
  providers: [StoriesService, ErrorService]
})
export class EditStoryComponent implements OnChanges {
  @Input() story: Story;
  @Input() storyAttributes: StoryAttribute[];
  @Input() projects: Project[];
  @Input() releases: Release[];
  @Input() iterations: Iteration[];
  @Input() teams: Team[];
  @Input() individuals: Individual[];
  @Input() me: Individual;
  @Input() hasPrevious: boolean;
  @Input() hasNext: boolean;
  @Output() closed: EventEmitter<any> = new EventEmitter();

  public model: Story;
  public customStoryAttributes: StoryAttribute[];
  public customValues: any = {};
  public error: String;

  constructor(private storiesService: StoriesService, private errorService: ErrorService) {
  }

  ngOnChanges(changes: any) {
    if (changes.story) {
      this.model = new Story(this.story);
      this.model.story_values.forEach((storyValue) => {
        this.customValues[storyValue.story_attribute_id] = storyValue.value;
      });
    }
    if (changes.storyAttributes) {
      let custom: StoryAttribute[] = [];
      this.storyAttributes.forEach((storyAttribute) => {
        if (storyAttribute.is_custom) {
          custom.push(storyAttribute);
          if (!this.customValues[storyAttribute.id]) {
            this.customValues[storyAttribute.id] = null;
          }
        }
      });
      this.customStoryAttributes = custom;
    }
  }

  isNew(): boolean {
    return this.model.id == null;
  }

  updateProject(): void {
    let storyId: number = parseInt(String(this.model.project_id), 10);
    this.model.project_id = storyId;
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
    return form.form.valid && this.me.canChangeBacklog();
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
    this.model.story_values = [];
    Object.keys(this.customValues).forEach((key) => {
      let value: string = this.customValues[key];
      this.model.story_values.push(new StoryValue({
        story_attribute_id: key,
        value: value === 'null' ? '' : value
      }));
    });
    let method: any = this.model.id ? this.storiesService.update : this.storiesService.create;
    method.call(this.storiesService, this.model).subscribe(
      (story: Story) => {
        if (!this.story.id) {
          this.story.added = true;
        }
        this.story.id = story.id;
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
  }
}
