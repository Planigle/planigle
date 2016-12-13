import { Component } from '@angular/core';
import { SessionsService } from '../sessions.service';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.css']
})
export class HeaderComponent {
  constructor(private sessionsService: SessionsService) { }

  logout() {
    this.sessionsService.logout();
  }
}
