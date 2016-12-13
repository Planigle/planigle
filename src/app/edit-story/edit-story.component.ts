import { Component, OnChanges, Input, Output, EventEmitter } from '@angular/core';
import { StoriesService } from '../stories.service';
import { ErrorService } from '../error.service';
import { Story } from '../story';
import { Project } from '../project';
import { Release } from '../release';
import { Iteration } from '../iteration';
import { Team } from '../team';
import { Individual } from '../individual';

@Component({
  selector: 'app-edit-story',
  templateUrl: './edit-story.component.html',
  styleUrls: ['./edit-story.component.css'],
  providers: [StoriesService, ErrorService]
})
export class EditStoryComponent implements OnChanges {
  @Input() story: Story;
  @Input() projects: Project[];
  @Input() releases: Release[];
  @Input() iterations: Iteration[];
  @Input() teams: Team[];
  @Input() individuals: Individual[];
  @Input() me: Individual;
  @Output() closed: EventEmitter<any> = new EventEmitter();

  public model: Story;
  public error: String;

  constructor(private storiesService: StoriesService, private errorService: ErrorService) {
  }

  ngOnChanges(changes) {
    if (changes.story) {
      this.model = new Story(this.story);
    }
  }

  isNew() {
    return this.model.id == null;
  }

  updateProject() {
    let storyId = parseInt(String(this.model.project_id), 10);
    this.model.project_id = storyId;
  }

  updateRelease() {
    if (String(this.model.release_id) === 'null') {
      this.model.release_id = null;
      this.model.release_name = null;
    } else {
      let storyId = parseInt(String(this.model.release_id), 10);
      this.model.release_id = storyId;
      this.releases.forEach((release: any) => {
        if (release.id === storyId) {
          this.model.release_name = release.name;
        };
      });
    }
  }

  updateIteration() {
    if (String(this.model.iteration_id) === 'null') {
      this.model.iteration_id = null;
      this.model.iteration_name = null;
    } else {
      let storyId = parseInt(String(this.model.iteration_id), 10);
      this.model.iteration_id = storyId;
      this.iterations.forEach((iteration: any) => {
        if (iteration.id === storyId) {
          this.model.iteration_name = iteration.name;
        };
      });
    }
  }

  updateTeam() {
    if (String(this.model.team_id) === 'null') {
      this.model.team_id = null;
      this.model.team_name = null;
    } else {
      let storyId = parseInt(String(this.model.team_id), 10);
      this.model.team_id = storyId;
      this.teams.forEach((team: any) => {
        if (team.id === storyId) {
          this.model.team_name = team.name;
        };
      });
    }
  }

  updateOwner() {
    if (String(this.model.individual_id) === 'null') {
      this.model.individual_id = null;
      this.model.individual_name = null;
    } else {
      let storyId = parseInt(String(this.model.individual_id), 10);
      this.model.individual_id = storyId;
      this.individuals.forEach((individual: any) => {
        if (individual.id === storyId) {
          this.model.individual_name = individual.name;
        };
      });
    }
  }

  ok() {
    let method = this.model.id ? this.storiesService.update : this.storiesService.create;
    method.call(this.storiesService, this.model).subscribe(
      (story: Story) => {
        if (!this.story.id) {
          this.story.added = true;
        }
        this.story.id = story.id;
        this.story.name = this.model.name;
        this.story.description = this.model.description;
        this.story.status_code = this.model.status_code;
        this.story.reason_blocked = this.model.reason_blocked;
        this.story.project_id = this.model.project_id;
        this.story.release_id = this.model.release_id;
        this.story.release_name = this.model.release_name;
        this.story.iteration_id = this.model.iteration_id;
        this.story.iteration_name = this.model.iteration_name;
        this.story.team_id = this.model.team_id;
        this.story.team_name = this.model.team_name;
        this.story.individual_id = this.model.individual_id;
        this.story.individual_name = this.model.individual_name;
        this.story.effort = this.model.effort;
        this.story.priority = story.priority;
        this.story.user_priority = story.user_priority;
        this.closed.next();
      },
      (err) => {
        this.error = this.errorService.getError(err);
      }
    );
  }

  cancel() {
    this.closed.next();
  }
}
