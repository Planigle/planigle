import { Component, Input, Output, EventEmitter } from '@angular/core';
import { SurveyMapping } from '../../models/survey-mapping';

@Component({
  selector: 'app-edit-suggestion',
  templateUrl: './edit-suggestion.component.html',
  styleUrls: ['./edit-suggestion.component.css']
})
export class EditSuggestionComponent {
  @Input() suggestion: SurveyMapping;
  @Output() finishedSuggesting: EventEmitter<any> = new EventEmitter();

  ok(): void {
    this.finishedSuggesting.emit({value: true});
  }

  cancel(): void {
    this.finishedSuggesting.emit({value: false});
  }
}
