import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { Iteration } from './iteration';

const baseUrl = 'api/iterations';

@Injectable()
export class IterationsService {
  constructor(private http: Http) { }

  getIterations(): Observable<Iteration[]> {
    return this.http.get(baseUrl)
      .map(res => res.json())
      .map((iterations: Array<any>) => {
        let result: Array<Iteration> = [];
        if (iterations) {
          iterations.forEach((iteration) => {
            result.push(
              new Iteration(iteration)
            );
          });
        }
        return result;
      });
  }
}
