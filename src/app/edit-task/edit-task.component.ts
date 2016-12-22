import { Component, OnChanges, Input, Output, EventEmitter } from '@angular/core';
import { TasksService } from '../tasks.service';
import { ErrorService } from '../error.service';
import { Task } from '../task';
import { Individual } from '../individual';

@Component({
  selector: 'app-edit-task',
  templateUrl: './edit-task.component.html',
  styleUrls: ['./edit-task.component.css'],
  providers: [TasksService, ErrorService]
})
export class EditTaskComponent implements OnChanges {
  @Input() task: Task;
  @Input() individuals: Individual[];
  @Input() me: Individual;
  @Output() closed: EventEmitter<any> = new EventEmitter();

  public model: Task;
  public error: String;

  constructor(private tasksService: TasksService, private errorService: ErrorService) {
  }

  ngOnChanges(changes) {
    if (changes.task) {
      this.model = new Task(this.task);
    }
  }

  isNew() {
    return this.model.id == null;
  }

  updateOwner() {
    if (String(this.model.individual_id) === 'null') {
      this.model.individual_id = null;
      this.model.individual_name = null;
    } else {
      let taskId = parseInt(String(this.model.individual_id), 10);
      this.model.individual_id = taskId;
      this.individuals.forEach((individual: any) => {
        if (individual.id === taskId) {
          this.model.individual_name = individual.name;
        };
      });
    }
  }

  updateEstimate() {
    this.model.effort = this.model.estimate;
  }

  ok() {
    let method = this.model.id ? this.tasksService.update : this.tasksService.create;
    method.call(this.tasksService, this.model).subscribe(
      (task: Task) => {
        if (!this.task.id) {
          this.task.added = true;
        }
        this.task.id = task.id;
        this.task.name = task.name;
        this.task.description = task.description;
        this.task.status_code = task.status_code;
        this.task.reason_blocked = task.reason_blocked;
        this.task.individual_id = task.individual_id;
        this.task.individual_name = task.individual_name;
        this.task.estimate = task.estimate;
        this.task.effort = task.effort;
        this.task.priority = task.priority;
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
