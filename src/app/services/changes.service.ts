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

  getChanges(user_id: number, object_type: string, start: Date, end: Date, object_id: number): Observable<Change[]> {
    let queryString = '';
    queryString = this.addParameter(queryString, 'user_id', user_id);
    queryString = this.addParameter(queryString, 'type', object_type);
    queryString = this.addParameter(queryString, 'start', this.getDateString(start));
    queryString = this.addParameter(queryString, 'end', this.getDateString(end));
    queryString = this.addParameter(queryString, 'object_id', object_id);
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
