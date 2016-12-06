import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { Team } from './team';

const baseUrl = 'api/projects/{project_id}/teams';

@Injectable()
export class TeamsService {
  constructor(private http: Http) { }

  getTeams(project_id: number): Observable<Team[]> {
    return this.http.get(baseUrl.replace(new RegExp('{project_id}'), '' + project_id))
      .map(res => res.json())
      .map((teams: Array<any>) => {
        let result: Array<Team> = [];
        if (teams) {
          teams.forEach((team) => {
            result.push(
              new Team(team)
            );
          });
        }
        return result;
      });
  }
}
