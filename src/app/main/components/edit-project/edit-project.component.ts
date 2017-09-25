import { Component, OnChanges, Input, Output, EventEmitter } from '@angular/core';
import { Router } from '@angular/router';
import { ProjectsService } from '../../services/projects.service';
import { ErrorService } from '../../services/error.service';
import { Project } from '../../models/project';
import { Status } from '../../models/status';
import { Individual } from '../../models/individual';
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-edit-project',
  templateUrl: './edit-project.component.html',
  styleUrls: ['./edit-project.component.css'],
  providers: [ProjectsService]
})
export class EditProjectComponent implements OnChanges {
  @Input() project: Project;
  @Input() me: Individual;
  @Output() closed: EventEmitter<any> = new EventEmitter();

  public model: Project;
  public error: String;
  selectedStatus: Status;
  statusTypes = [
    {
      name: 'Not Started',
      code:  0
    }, {
      name: 'In Progress',
      code:  1
    }, {
      name: 'Blocked',
      code:  2
    }, {
      name: 'Done',
      code:  3
    }
  ];

  constructor(
    private router: Router,
    private projectsService: ProjectsService,
    private errorService: ErrorService) {
  }

  ngOnChanges(changes): void {
    if (changes.project) {
      this.model = new Project(this.project);
      setTimeout(() => $('input[autofocus=""]').focus(), 0);
    }
  }

  isNew(): boolean {
    return this.model.id == null;
  }

  canSave(form: any): boolean {
    return form.form.valid && this.canUpdate();
  }

  canUpdate(): boolean {
    return this.me.canChangePeople();
  }

  ok(): void {
    this.saveModel(FinishedEditing.Save, null);
  }

  cancel(): void {
    this.closed.emit({value: FinishedEditing.Cancel});
  }

  addAnother(form): void {
    this.saveModel(FinishedEditing.AddAnother, form);
  }

  private saveModel(result: FinishedEditing, form: any): void {
    let method: any = this.model.id ? this.projectsService.update : this.projectsService.create;
    method.call(this.projectsService, this.model).subscribe(
      (project: Project) => {
        if (!this.project.id) {
          this.project.added = true;
        }
        this.project.id = project.id;
        this.project.name = project.name;
        this.project.description = project.description;
        this.project.track_actuals = project.track_actuals;
        this.project.survey_mode = project.survey_mode;
        this.project.statuses = [];
        project.statuses.forEach((status) => {
          this.project.statuses.push(new Status(status));
        });
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

  viewChanges(): void {
    this.router.navigate(['changes', {type: 'Project', id: this.model.id}]);
  }

  selectStatus(status: Status): void {
    this.selectedStatus = status;
    setTimeout(function() {
      $('textarea[ordering="' + status.ordering + '"]').select();
    });
  }

  addStatus(statusType: number): void {
    let status: Status = this.newStatus(statusType);
    this.model.statuses.splice(this.lastStatus(statusType) + 1, 0, status);
    this.updateOrdering();
    this.selectStatus(status);
  }

  canMoveUp(status: Status): boolean {
    let statuses: Array<Status> = this.statusesOfType(status.status_code);
    return statuses.indexOf(status) > 0;
  }

  moveUp(status: Status): void {
    if (this.canMoveUp(status)) {
      let index = this.model.statuses.indexOf(status);
      this.model.statuses.splice(index, 1);
      this.model.statuses.splice(index - 1, 0, status);
      this.updateOrdering();
    }
  }

  canMoveDown(status: Status): boolean {
    let statuses: Array<Status> = this.statusesOfType(status.status_code);
    return statuses.indexOf(status) < statuses.length - 1;
  }

  moveDown(status: Status): void {
    if (this.canMoveDown(status)) {
      let index = this.model.statuses.indexOf(status);
      this.model.statuses.splice(index, 1);
      this.model.statuses.splice(index + 1, 0, status);
      this.updateOrdering();
    }
  }

  private statusesOfType(statusCode: number): Array<Status> {
    let result: Array<Status> = [];
    for (let i = 0; i < this.model.statuses.length; i++) {
      if (this.model.statuses[i].status_code === statusCode) {
        result.push(this.model.statuses[i]);
      }
    }
    return result;
  }

  private newStatus(statusCode: number): Status {
    return new Status({
      project_id: this.model.id,
      name: 'New Status',
      status_code: statusCode,
      applies_to_stories: true,
      applies_to_tasks: true
    });
  }

  private lastStatus(statusCode: number): number {
    let lastIndex = 0;
    for (let i = 0; i < this.model.statuses.length; i++) {
      if (this.model.statuses[i].status_code === statusCode) {
        lastIndex = i;
      }
    }
    return lastIndex;
  }

  hasMoreThanOne(statusCode: number): boolean {
    let count = 0;
    for (let i = 0; i < this.model.statuses.length; i++) {
      if (this.model.statuses[i].status_code === statusCode) {
        count++;
        if (count > 1) {
          return true;
        }
      }
    }
    return false;
  }

  deleteStatus(status: Status): void {
    this.model.statuses.splice(this.model.statuses.indexOf(status), 1);
    this.updateOrdering();
  }

  isSelectedStatus(status: Status): boolean {
    return this.selectedStatus === status;
  }

  handleStatusKeyStroke(event): void {
    this.handleKeyStroke(event, this.model.statuses, this.selectedStatus, this.selectStatus);
  }

  private handleKeyStroke(event, values: any[], selection, select): void {
    let key: string = event.key;
    let index: number = values === null ? null : values.indexOf(selection);
    if (key === 'ArrowDown' || key === 'Enter') {
      if (index !== -1 && index < values.length - 1) {
        select.call(this, values[index + 1]);
      }
      event.preventDefault();
    } else if (key === 'ArrowUp') { // up arrow
      if (index !== -1 && index > 0) {
        select.call(this, values[index - 1]);
      }
      event.preventDefault();
    }
  }

  private updateOrdering(): void {
    for (let i = 0; i < this.model.statuses.length; i++) {
      this.model.statuses[i].ordering = i + 1;
    }
  }
}
