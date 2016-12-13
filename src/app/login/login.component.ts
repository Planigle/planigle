import { Component } from '@angular/core';
import { SessionsService } from '../sessions.service';
import { ApiResponse } from '../api_response';
import { Credentials } from '../credentials';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent {
  public user: Credentials = new Credentials('', '');
  public response: ApiResponse = new ApiResponse('');

  constructor(private sessionsService: SessionsService) {
  }

  login(acceptAgreement) {
      this.sessionsService.login(this.user, this.response, acceptAgreement, null);
  }

  acceptAgreement() {
    this.login(true);
  }

  declineAgreement() {
    alert('You must Accept in order to use the application');
  }
}
