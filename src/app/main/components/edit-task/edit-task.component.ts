import { Component, OnChanges, Input, Output, EventEmitter } from '@angular/core';
import { Router } from '@angular/router';
import { TasksService } from '../../services/tasks.service';
import { ErrorService } from '../../services/error.service';
import { Task } from '../../models/task';
import { Individual } from '../../models/individual';
import { Status } from '../../models/status';
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-edit-task',
  templateUrl: './edit-task.component.html',
  styleUrls: ['./edit-task.component.css'],
  providers: [TasksService, ErrorService]
})
export class EditTaskComponent implements OnChanges {
  @Input() task: Task;
  @Input() individuals: Individual[];
  @Input() statuses: Status[];
  @Input() me: Individual;
  @Input() showActuals: boolean = false;
  @Input() hasPrevious: boolean;
  @Input() hasNext: boolean;
  @Output() closed: EventEmitter<any> = new EventEmitter();

  public model: Task;
  public error: String;

  constructor(
    private router: Router,
    private tasksService: TasksService,
    private errorService: ErrorService) {
  }

  ngOnChanges(changes): void {
    if (changes.task) {
      this.model = new Task(this.task);
      setTimeout(() => $('input[autofocus=""]').focus(), 0);
    }
  }

  isNew(): boolean {
    return this.model.id == null;
  }

  updateOwner(): void {
    if (String(this.model.individual_id) === 'null') {
      this.model.individual_id = null;
      this.model.individual_name = null;
    } else {
      let taskId: number = parseInt(String(this.model.individual_id), 10);
      this.model.individual_id = taskId;
      this.individuals.forEach((individual: any) => {
        if (individual.id === taskId) {
          this.model.individual_name = individual.name;
        };
      });
    }
  }

  updateEstimate(): void {
    this.model.effort = this.model.estimate;
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
    if (this.me.canChangeBacklog()) {
      let method: any = this.model.id ? this.tasksService.update : this.tasksService.create;
      method.call(this.tasksService, this.model).subscribe(
        (task: Task) => {
          if (!this.task.id) {
            this.task.added = true;
          }
          this.task.id = task.id;
          this.task.name = task.name;
          this.task.description = task.description;
          this.task.status_id = task.status_id;
          this.task.status_code = task.status_code;
          this.task.reason_blocked = task.reason_blocked;
          this.task.individual_id = task.individual_id;
          this.task.individual_name = task.individual_name;
          this.task.estimate = task.estimate;
          this.task.effort = task.effort;
          this.task.actual = task.actual;
          this.task.priority = task.priority;
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

  viewChanges(): void {
    this.router.navigate(['changes', {type: 'Task', id: this.model.id}]);
  }
}
