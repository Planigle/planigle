import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Params } from '@angular/router';
import { SessionsService } from '../../services/sessions.service';
import { ErrorService } from '../../services/error.service';
import { ApiResponse } from '../../models/api_response';
import { Credentials } from '../../models/credentials';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {
  public user: Credentials = new Credentials('', '');
  public response: ApiResponse = new ApiResponse('');

  constructor(
    private route: ActivatedRoute,
    private sessionsService: SessionsService,
    private errorService: ErrorService) {
  }

  ngOnInit() {
    this.route.params.subscribe((params: Map<string, string>) => {
        if (params['login']) {
          this.user.login = params['login'];
        }
        if (params['token']) {
          this.user.token = params['token'];
          this.sessionsService.login(this.user, this.response, false, null);
        }
      });
  }

  login(acceptAgreement): void {
      this.sessionsService.login(this.user, this.response, acceptAgreement, null);
  }

  forgotPassword(): void {
    if (this.user.login.trim() === '') {
      this.response.error = 'Please enter your User Name';
    } else {
      this.sessionsService.forgotPassword(this.user, this.response);
    }
  }

  acceptAgreement(): void {
    this.login(true);
  }

  declineAgreement(): void {
    this.errorService.showError('You must Accept in order to use the application');
  }
}
