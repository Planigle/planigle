import { Injectable } from '@angular/core';
import { Router, ActivatedRouteSnapshot, RouterStateSnapshot, CanActivate } from '@angular/router';
import { SessionsService } from './sessions.service';
import { ApiResponse } from '../models/api_response';

@Injectable()
export class AuthGuardService implements CanActivate {
  constructor(private sessionsService: SessionsService, private router: Router) { }

  canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean {
    let user = this.sessionsService.getCurrentUser();
    if (user) {
      return true;
    } else {
      this.sessionsService.login(null, new ApiResponse(''), false, state.url);
      return false;
    }
  }
}
