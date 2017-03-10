import { Component } from '@angular/core';
import { Notifier } from '../../models/notifier';

@Component({
  selector: 'app-people',
  templateUrl: './people.component.html',
  styleUrls: ['./people.component.css']
})
export class PeopleComponent {
  notifier: Notifier = new Notifier();

  public projectsChanged(): void {
    this.notifier.notify();
  }
}
