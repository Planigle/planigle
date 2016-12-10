import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Router } from '@angular/router';
import { Headers, RequestOptions } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { ErrorService } from './error.service';
import { ApiResponse } from './api_response';
import { Credentials } from './credentials';
import { Individual } from './individual';
declare var $: any;

const baseUrl = 'api/session';

@Injectable()
export class SessionsService {
  private current_user: Individual;

  constructor(private router: Router, private http: Http, private errorService: ErrorService) { }

  login(user: Credentials, response: ApiResponse, acceptAgreement: boolean): Observable<Individual> {
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });
    let observable: Observable<Individual> =
      this.http.post(baseUrl + (acceptAgreement ? '?accept_agreement=true' : ''), user ? JSON.stringify(user) : null, options)
      .map(res => res.json())
      .share();
    observable
      .subscribe(
        (loggedInUser) => {
          this.current_user = new Individual(loggedInUser);
          this.router.navigate(['/stories']);
        },
        (err) => {
          let error = this.errorService.getError(err);
          if (error === 'You must accept the license agreement to proceed') {
            let agreement = err.json().agreement;
            $('#agreementDialog').one('show.bs.modal', function (event) {
              $(this).find('.modal-title').text('License Agreement');
              $(this).find('.modal-body').html(agreement.replace(/\r/g, '<br>'));
            }).modal();
          } else {
            response.error = error;
          }
        });
    return observable;
  }

  getCurrentUser(): Individual {
    return this.current_user;
  }

  logout() {
    this.http.delete(baseUrl)
      .map(res => res.json())
      .subscribe(
        (data) => {
          this.current_user = null;
          this.forceLogin();
        }
      );
  }

  forceLogin() {
    this.router.navigate(['/login']);
  }
}
