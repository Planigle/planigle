import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Router } from '@angular/router';
import { Headers, RequestOptions } from '@angular/http';
import { ErrorService } from '../services/error.service';
import { ApiResponse } from '../models/api_response';
import { Credentials } from '../models/credentials';
import { Individual } from '../models/individual';
declare var $: any;

const baseUrl = 'api/session';

@Injectable()
export class SessionsService {
  private current_user: Individual;
  private path: string = '/stories';

  constructor(private router: Router, private http: Http, private errorService: ErrorService) { }

  login(user: Credentials, response: ApiResponse, acceptAgreement: boolean, url: string): void {
    if (url) {
      this.path = url;
    }
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });
    let self = this;
    self.http.post(baseUrl + (acceptAgreement ? '?accept_agreement=true' : ''), user ? JSON.stringify(user) : null, options)
    .map(res => res.json())
    .subscribe(
      (loggedInUser: any) => {
        self.current_user = new Individual(loggedInUser);
        self.forceLogin(); // Otherwise it won't retry current page
        self.router.navigateByUrl(user.token != null ? ('people;individual=' + loggedInUser.id) : self.path);
      },
      (err: any) => {
        if (url) {
          self.forceLogin();
        } else {
          let error: string = self.errorService.getError(err);
          if (error === 'You must accept the license agreement to proceed') {
            let agreement = err.json().agreement;
            $('#agreementDialog').one('show.bs.modal', function (event) {
              $('.modal-title').text('License Agreement');
              $('.modal-body').html(agreement.replace(/\r/g, '<br>'));
              setTimeout(() => $('#agreementDialog input[autofocus]').focus(), 500);
            }).modal();
          } else {
            response.error = error;
          }
        }
      });
  }

  forgotPassword(user: Credentials, response: ApiResponse): void {
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });
    this.http.post(baseUrl + '/reset_password', JSON.stringify(user), options)
    .map(res => res.json())
    .subscribe(
      () => {
        response.error = 'A temporary login URL was sent to the email associated with the specified login.  ' +
          'If you do not receive it, please double check the login and check your spam folder.';
      });
  }

  getCurrentUser(): Individual {
    return this.current_user;
  }

  logout(): void {
    this.http.delete(baseUrl).subscribe(
      (response: any) => this.forceLogout(),
      (err: any) => this.forceLogout()
    );
  }

  private forceLogout(): void {
    this.current_user = null;
    this.path = '/stories';
    this.forceLogin();
  }

  forceLogin(): void {
    this.router.navigateByUrl('/login');
  }
}
