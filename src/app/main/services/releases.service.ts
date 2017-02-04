import { Injectable } from '@angular/core';
import { Http, Headers, RequestOptions } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { Release } from '../models/release';

const baseUrl = 'api/releases';

@Injectable()
export class ReleasesService {
  constructor(private http: Http) { }

  getReleases(historical?: boolean): Observable<Release[]> {
    return this.http.get(baseUrl + (historical ? '?historical=true' : ''))
      .map(res => res.json())
      .map((releases: Array<any>) => {
        let result: Array<Release> = [];
        if (releases) {
          releases.forEach((release: any) => {
            result.push(
              new Release(release)
            );
          });
        }
        return result;
      });
  }

  create(release: Release): Observable<Release> {
    return this.createOrUpdate(release, this.http.post, '');
  }

  update(release: any): Observable<Release> {
    return this.createOrUpdate(release, this.http.put, '/' + release.id);
  }

  delete(release: Release): Observable<Release> {
    return this.http.delete(baseUrl + '/' + release.id)
      .map((res: any) => res.json())
      .map((response: any) => {
        if (response.hasOwnProperty('record')) {
          return new Release(response.record);
        } else {
          return new Release(response);
        }
      });
  }

  private createOrUpdate(release: any, method, idString): Observable<Release> {
    let headers: Headers = new Headers({ 'Content-Type': 'application/json' });
    let options: RequestOptions = new RequestOptions({ headers: headers });
    let record: any = {
      name: release.name,
      start: release.startStringYearFirst,
      finish: release.finishStringYearFirst
    };
    return method.call(this.http, baseUrl + idString, {record: record}, options)
      .map((res: any) => res.json())
      .map((updatedRelease: any) => {
        return new Release(updatedRelease);
      });
  }
}
