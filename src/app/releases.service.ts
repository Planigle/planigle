import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { Release } from './release';

const baseUrl = 'api/releases';

@Injectable()
export class ReleasesService {
  constructor(private http: Http) { }

  getReleases(): Observable<Release[]> {
    return this.http.get(baseUrl)
      .map(res => res.json())
      .map((releases: Array<any>) => {
        let result: Array<Release> = [];
        if (releases) {
          releases.forEach((release) => {
            result.push(
              new Release(release)
            );
          });
        }
        return result;
      });
  }
}
