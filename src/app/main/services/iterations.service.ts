import { Injectable } from '@angular/core';
import { Http, Headers, RequestOptions } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { Iteration } from '../models/iteration';

const baseUrl = 'api/iterations';

@Injectable()
export class IterationsService {
  constructor(private http: Http) { }

  getIterations(historical?: boolean): Observable<Iteration[]> {
    return this.http.get(baseUrl + (historical ? '?historical=true' : ''))
      .map(res => res.json())
      .map((iterations: Array<any>) => {
        let result: Array<Iteration> = [];
        if (iterations) {
          iterations.forEach((iteration: any) => {
            result.push(
              new Iteration(iteration)
            );
          });
        }
        return result;
      });
  }

  create(iteration: Iteration): Observable<Iteration> {
    return this.createOrUpdate(iteration, this.http.post, '');
  }

  update(iteration: any): Observable<Iteration> {
    return this.createOrUpdate(iteration, this.http.put, '/' + iteration.id);
  }

  delete(iteration: Iteration): Observable<Iteration> {
    return this.http.delete(baseUrl + '/' + iteration.id)
      .map((res: any) => res.json())
      .map((response: any) => {
        if (response.hasOwnProperty('record')) {
          return new Iteration(response.record);
        } else {
          return new Iteration(response);
        }
      });
  }

  private createOrUpdate(iteration: any, method, idString): Observable<Iteration> {
    let headers: Headers = new Headers({ 'Content-Type': 'application/json' });
    let options: RequestOptions = new RequestOptions({ headers: headers });
    let record: any = {
      name: iteration.name,
      start: iteration.startStringYearFirst,
      finish: iteration.finishStringYearFirst,
      notable: iteration.notable,
      retrospective_results: iteration.retrospective_results
    };
    return method.call(this.http, baseUrl + idString, {record: record}, options)
      .map((res: any) => res.json())
      .map((updatedIteration: any) => {
        return new Iteration(updatedIteration);
      });
  }
}
