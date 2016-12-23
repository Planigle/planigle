import { Component } from '@angular/core';
import { SessionsService } from '../../services/sessions.service';
import { ApiResponse } from '../../models/api_response';
import { Credentials } from '../../models/credentials';

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

  login(acceptAgreement): void {
      this.sessionsService.login(this.user, this.response, acceptAgreement, null);
  }

  acceptAgreement(): void {
    this.login(true);
  }

  declineAgreement(): void {
    alert('You must Accept in order to use the application');
  }
}
