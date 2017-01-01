import { Component, Input, Output, EventEmitter } from '@angular/core';
import { StoryAttribute } from '../../models/story-attribute'
import { Individual } from '../../models/individual'

@Component({
  selector: 'app-custom-attributes',
  templateUrl: './custom-attributes.component.html',
  styleUrls: ['./custom-attributes.component.css']
})
export class CustomAttributesComponent {
  @Input() customStoryAttributes: StoryAttribute[] = [];
  @Input() customValues: Map<string,any> = new Map();
  @Input() releaseId: number;
  @Input() me: Individual;
  @Input() filter: boolean = false;
  @Input() multiple: boolean = false;
  @Output() changed: EventEmitter<any> = new EventEmitter();
  
  constructor() { }
  
  valueChanged(): void {
    this.changed.next();
  }
}
