import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { DatesService } from './dates.service';
import { Change} from '../models/change';

const baseUrl = 'api/audits';

@Injectable()
export class ChangesService {
  constructor(
    private http: Http,
    private datesService: DatesService
  ) { }

  getChanges(user_id: number, object_type: string, start: Date, end: Date, object_id: number, page: number): Observable<Change[]> {
    let queryString = this.getQueryString(user_id, object_type, start, end, object_id);
    queryString = this.addParameter(queryString, 'page', page);
    return this.http.get(baseUrl + queryString)
      .map(res => res.json())
      .map((changes: Array<any>) => {
        let result: Array<Change> = [];
        if (changes) {
          changes.forEach((change: any) => {
            result.push(
              new Change(change)
            );
          });
        }
        return result;
      });
  }

  getNumPages(user_id: number, object_type: string, start: Date, end: Date, object_id: number): Observable<number> {
    return this.http.get(baseUrl + '/num_pages' + this.getQueryString(user_id, object_type, start, end, object_id))
      .map(res => res.json());
  }

  private getQueryString(user_id: number, object_type: string, start: Date, end: Date, object_id: number): string {
    let queryString = '';
    queryString = this.addParameter(queryString, 'user_id', user_id);
    queryString = this.addParameter(queryString, 'type', object_type);
    queryString = this.addParameter(queryString, 'start', this.getDateString(start));
    queryString = this.addParameter(queryString, 'end', this.getDateString(end));
    queryString = this.addParameter(queryString, 'object_id', object_id);
    return queryString;
  }

  private addParameter(queryString: string, param: string, value: any) {
    if (value != null) {
      queryString += queryString.length === 0 ? '?' : '&';
      queryString += param;
      queryString += '=';
      queryString += value;
    }
    return queryString;
  }

  private getDateString(date: Date): string {
    return this.datesService.getDateStringYearFirst(date);
  }
}
