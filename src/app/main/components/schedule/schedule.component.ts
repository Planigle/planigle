import { Component } from '@angular/core';
declare var $: any;

@Component({
  selector: 'app-schedule',
  templateUrl: './schedule.component.html',
  styleUrls: ['./schedule.component.css']
})
export class ScheduleComponent {
  ScheduleComponent() {
    $.contextMenu('destroy');
  }
}
