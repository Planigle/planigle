import { Component, AfterViewInit } from '@angular/core';
declare var $: any;

@Component({
  selector: 'app-schedule',
  templateUrl: './schedule.component.html',
  styleUrls: ['./schedule.component.css']
})
export class ScheduleComponent implements AfterViewInit {
  constructor() { }

  ngAfterViewInit(): void {
    this.setHeight();
    $(window).resize(this.setHeight);
  }
  
  setHeight(): void {
    $('.content').height($(window).height() - $('app-header').height() - 5);
  }
}
