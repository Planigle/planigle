import { Injectable } from '@angular/core';
import { Response } from '@angular/http';

@Injectable()
export class ErrorService {
  constructor() { }

  getError(error: any): string {
    if (error instanceof Response) {
      if (error.text() !== '') {
        const body = error.json() || '';
        return body.error || JSON.stringify(body);
      } else {
        return error.statusText;
      }
    } else {
      return error.message ? error.message : error.toString();
    }
  }
}
