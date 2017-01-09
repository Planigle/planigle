import { Injectable } from '@angular/core';
import { Http, Headers, RequestOptions } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { Team } from '../models/team';

const baseUrl = 'api/projects/{project_id}/teams';

@Injectable()
export class TeamsService {
  constructor(private http: Http) { }

  getTeams(project_id: number): Observable<Team[]> {
    return this.http.get(baseUrl.replace(new RegExp('{project_id}'), '' + project_id))
      .map((res: any) => res.json())
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
  
  create(team: Team): Observable<Team> {
    return this.createOrUpdate(team, this.http.post, '');
  }

  update(team: Team): Observable<Team> {
    return this.createOrUpdate(team, this.http.put, '/' + team.id);
  }

  delete(team: Team): Observable<Team> {
    return this.http.delete(baseUrl + '/' + team.id)
      .map((res: any) => res.json())
      .map((response: any) => {
        if (response.hasOwnProperty('record')) {
          return new Team(response.record);
        } else {
          return new Team(response);
        }
      });
  }

  private createOrUpdate(team: Team, method, idString): Observable<Team> {
    let headers: Headers = new Headers({ 'Content-Type': 'application/json' });
    let options: RequestOptions = new RequestOptions({ headers: headers });
    let record: any = {
      name: team.name,
      description: team.description,
      project_id: team.project_id
    };
    return method.call(this.http, baseUrl.replace(new RegExp('{project_id}'), '' + team.project_id) + idString, {record: record}, options)
      .map((res: any) => res.json())
      .map((updatedTeam: any) => {
        return new Team(updatedTeam);
      });
  }
}
