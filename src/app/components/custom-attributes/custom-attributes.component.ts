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
  @Input() releaseId: number;
  @Input() me: Individual;
  @Input() filter: boolean = false;
  @Input() multiple: boolean = false;
  @Output() changed: EventEmitter<any> = new EventEmitter();

  constructor() { }

  ngOnChanges(changes): void {
    if (changes.releaseId) {
      this.customStoryAttributes.forEach((attribute: StoryAttribute) => {
        if (attribute.hasReleaseList()) {
          if (attribute.getValuesForRelease(this.releaseId).indexOf(this.customValues[attribute.id]) === -1) {
            this.customValues[attribute.id] = 'null';
          }
        }
      });
    }
  }

  valueChanged(): void {
    this.changed.next();
  }
}
