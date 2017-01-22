import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-stories-summary',
  templateUrl: './stories-summary.component.html',
  styleUrls: ['./stories-summary.component.css']
})
export class StoriesSummaryComponent {
  @Input() public numberOfStories: number = 0;
  @Input() public velocityAllocation: Map<any, number>;
  @Input() public storyAllocation: Map<any, number>;
}
