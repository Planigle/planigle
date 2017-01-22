import { Component, Input } from '@angular/core';
import { ReleasesComponent } from '../releases/releases.component';

@Component({
  selector: 'app-release-overall-actions',
  templateUrl: './release-overall-actions.component.html',
  styleUrls: ['./release-overall-actions.component.css']
})
export class ReleaseOverallActionsComponent {
  @Input() grid: ReleasesComponent;

  constructor() { }

  addRelease() {
    this.grid.addRelease();
  }
}
