import { Component, Input } from '@angular/core';
import { IterationsComponent } from '../iterations/iterations.component';

@Component({
  selector: 'app-iteration-overall-actions',
  templateUrl: './iteration-overall-actions.component.html',
  styleUrls: ['./iteration-overall-actions.component.css']
})
export class IterationOverallActionsComponent {
  @Input() grid: IterationsComponent;

  constructor() { }

  addIteration(): void {
    this.grid.addIteration();
  }
}
