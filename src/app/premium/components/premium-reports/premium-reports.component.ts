import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-premium-reports',
  templateUrl: './premium-reports.component.html',
  styleUrls: ['./premium-reports.component.css']
})
export class PremiumReportsComponent {
  static height: number = 0;
  @Input() user: any;
  @Input() teams: any[];
  @Input() releases: any[];
  @Input() iterations: any[];
}
