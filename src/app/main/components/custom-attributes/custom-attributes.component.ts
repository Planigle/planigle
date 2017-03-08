import { Component, Input, Output, EventEmitter, OnChanges } from '@angular/core';
import { StoryAttribute } from '../../models/story-attribute';
import { Individual } from '../../models/individual';

@Component({
  selector: 'app-custom-attributes',
  templateUrl: './custom-attributes.component.html',
  styleUrls: ['./custom-attributes.component.css']
})
export class CustomAttributesComponent implements OnChanges {
  @Input() customStoryAttributes: StoryAttribute[] = [];
  @Input() customValues: Map<string, any> = new Map();
  @Input() customNumericValues: Map<string, number> = new Map();
  @Input() releaseId: number;
  @Input() me: Individual;
  @Input() filter: boolean = false;
  @Input() multiple: boolean = false;
  @Output() changed: EventEmitter<any> = new EventEmitter();

  ngOnChanges(changes): void {
    let self: CustomAttributesComponent = this;
    if (changes.hasOwnProperty('releaseId') && !this.filter && !this.multiple) {
      this.customStoryAttributes.forEach((attribute: StoryAttribute) => {
        if (attribute.hasReleaseList()) {
          if (attribute.getValuesStringsForRelease(self.releaseId).indexOf(self.customValues[attribute.id]) === -1) {
            self.customValues[attribute.id] = 'null';
          }
        }
      });
    }
  }

  valueChanged(): void {
    this.changed.next();
  }
}
