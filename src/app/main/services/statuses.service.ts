import { Injectable } from '@angular/core';
import { Http, Headers, RequestOptions } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { Status } from '../models/status';

const baseUrl = 'api/statuses';

@Injectable()
export class StatusesService {
  constructor(private http: Http) { }

  getStatuses(): Observable<Status[]> {
    return this.http.get(baseUrl)
      .map(res => res.json())
      .map((statuses: Array<any>) => {
        let result: Array<Status> = [];
        if (statuses) {
          statuses.forEach((status: any) => {
            result.push(
              new Status(status)
            );
          });
        }
        return result;
      });
  }

  create(status: Status): Observable<Status> {
    return this.createOrUpdate(status, this.http.post, '');
  }

  update(status: any): Observable<Status> {
    return this.createOrUpdate(status, this.http.put, '/' + status.id);
  }

  delete(status: Status): Observable<Status> {
    return this.http.delete(baseUrl + '/' + status.id)
      .map((res: any) => res.json())
      .map((response: any) => {
        if (response.hasOwnProperty('record')) {
          return new Status(response.record);
        } else {
          return new Status(response);
        }
      });
  }

  private createOrUpdate(status: any, method, idString): Observable<Status> {
    let headers: Headers = new Headers({ 'Content-Type': 'application/json' });
    let options: RequestOptions = new RequestOptions({ headers: headers });
    let record: any = {
      name: status.name,
      project_id: status.project_id,
      ordering: status.ordering,
      status_code: status.status_code,
      applies_to_stories: status.applies_to_stories,
      applies_to_tasks: status.applies_to_tasks
    };
    return method.call(this.http, baseUrl + idString, {record: record}, options)
      .map((res: any) => res.json())
      .map((updatedStatus: any) => {
        return new Status(updatedStatus);
      });
  }
}
