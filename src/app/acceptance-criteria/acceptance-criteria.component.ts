import { Component, OnChanges, Input } from '@angular/core';
import { AcceptanceCriterium } from '../acceptance-criterium';
declare var $: any;

@Component({
  selector: 'app-acceptance-criteria',
  templateUrl: './acceptance-criteria.component.html',
  styleUrls: ['./acceptance-criteria.component.css']
})
export class AcceptanceCriteriaComponent implements OnChanges {
  @Input() model: any;
  criteriumToEdit: AcceptanceCriterium;
  addedId: number = -1;

  constructor() { }

  ngOnChanges(changes) {
    if (changes.model) {
      this.ensureAtLeastOneCriterium();
    }
  }

  editCriterium(criterium) {
    this.criteriumToEdit = null;
    setTimeout(() => {
      this.criteriumToEdit = criterium;
      setTimeout(() => {
          $('#edit-' + criterium.id).focus();
      }, 100);
    }, 100);
  }

  stopEditingCriterium() {
    this.criteriumToEdit = null;
  }

  deleteCriterium(criterium) {
    this.model.acceptance_criteria.splice(this.model.acceptance_criteria.indexOf(criterium), 1);
    this.ensureAtLeastOneCriterium();
  }

  handleKeyStroke(event) {
    let key = event.key;
    let index = this.criteriumToEdit === null ? null : this.model.acceptance_criteria.indexOf(this.criteriumToEdit);
    if (key === 'ArrowDown' || key === 'Enter') {
      if (index !== -1 && index < this.model.acceptance_criteria.length - 1) {
        this.editCriterium(this.model.acceptance_criteria[index + 1]);
      } else {
        this.addAcceptanceCriteria('');
        this.editCriterium(this.model.acceptance_criteria[this.model.acceptance_criteria.length - 1]);
      }
      event.preventDefault();
    } else if (key === 'ArrowUp') { // up arrow
      if (index !== -1 && index > 0) {
        this.editCriterium(this.model.acceptance_criteria[index - 1]);
      }
      event.preventDefault();
    }
  }

  private ensureAtLeastOneCriterium() {
    if (this.model.acceptance_criteria.length === 0) {
      this.addAcceptanceCriteria('<Enter criteria here; Press Enter or down arrow to add additional>');
    }
  }

  private addAcceptanceCriteria(description) {
    this.model.acceptance_criteria.push(new AcceptanceCriterium({
      id: this.addedId,
      description: description,
      status_code: 0
    }));
    this.addedId -= 1;
  }
}
