import { Component, Input } from '@angular/core';
import { IndividualsComponent } from '../individuals/individuals.component';

@Component({
  selector: 'app-individual-overall-actions',
  templateUrl: './individual-overall-actions.component.html',
  styleUrls: ['./individual-overall-actions.component.css']
})
export class IndividualOverallActionsComponent {
  @Input() grid: IndividualsComponent;

  constructor() { }

  addIndividual(): void {
    this.grid.addIndividual();
  }
}
