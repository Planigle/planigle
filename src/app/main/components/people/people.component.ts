import { Component } from '@angular/core';
import { Notifier } from '../../models/notifier';
declare var $: any;

@Component({
  selector: 'app-people',
  templateUrl: './people.component.html',
  styleUrls: ['./people.component.css']
})
export class PeopleComponent {
  projectNotifier: Notifier = new Notifier();
  teamNotifier: Notifier = new Notifier();

  PeopleComponent() {
    $.contextMenu('destroy');
  }

  public projectsChanged(): void {
    this.projectNotifier.notify();
  }

  public teamsChanged(): void {
    this.teamNotifier.notify();
  }
}
