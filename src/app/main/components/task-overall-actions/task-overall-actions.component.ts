import { Component, Input } from '@angular/core';
import { TasksComponent } from '../tasks/tasks.component';

@Component({
  selector: 'app-task-overall-actions',
  templateUrl: './task-overall-actions.component.html',
  styleUrls: ['./task-overall-actions.component.css']
})
export class TaskOverallActionsComponent {
  @Input() grid: TasksComponent;

  refresh(): void {
    this.grid.refresh();
  }
}
