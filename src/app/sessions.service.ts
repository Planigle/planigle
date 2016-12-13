import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Router } from '@angular/router';
import { Headers, RequestOptions } from '@angular/http';
import { ErrorService } from './error.service';
import { ApiResponse } from './api_response';
import { Credentials } from './credentials';
import { Individual } from './individual';
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
      (loggedInUser) => {
        self.current_user = new Individual(loggedInUser);
        self.forceLogin(); // Otherwise it won't retry current page
        self.router.navigate([self.path]);
      },
      (err) => {
        if (url) {
          self.forceLogin();
        } else {
          let error = self.errorService.getError(err);
          if (error === 'You must accept the license agreement to proceed') {
            let agreement = err.json().agreement;
            $('#agreementDialog').one('show.bs.modal', function (event) {
              $(self).find('.modal-title').text('License Agreement');
              $(self).find('.modal-body').html(agreement.replace(/\r/g, '<br>'));
            }).modal();
          } else {
            response.error = error;
          }
        }
      });
  }

  getCurrentUser(): Individual {
    return this.current_user;
  }

  logout() {
    this.http.delete(baseUrl).subscribe(
      (response) => this.forceLogout(),
      (err) => this.forceLogout()
    );
  }

  private forceLogout() {
    this.current_user = null;
    this.path = '/stories';
    this.forceLogin();
  }

  forceLogin() {
    this.router.navigateByUrl('/login');
  }
}
