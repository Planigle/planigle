import { Injectable } from '@angular/core';
import { Http, Headers, RequestOptions } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { Individual } from '../models/individual';

const baseUrl = 'api/individuals';

@Injectable()
export class IndividualsService {
  constructor(private http: Http) { }

  getIndividuals(): Observable<Individual[]> {
    return this.http.get(baseUrl)
      .map(res => res.json())
      .map((individuals: Array<any>) => {
        let result: Array<Individual> = [];
        if (individuals) {
          individuals.forEach((individual: any) => {
            result.push(
              new Individual(individual)
            );
          });
        }
        return result;
      });
  }

  create(individual: Individual): Observable<Individual> {
    return this.createOrUpdate(individual, this.http.post, '');
  }

  update(individual: Individual): Observable<Individual> {
    return this.createOrUpdate(individual, this.http.put, '/' + individual.id);
  }

  delete(individual: Individual): Observable<Individual> {
    return this.http.delete(baseUrl + '/' + individual.id)
      .map((res: any) => res.json())
      .map((response: any) => {
        if (response.hasOwnProperty('record')) {
          return new Individual(response.record);
        } else {
          return new Individual(response);
        }
      });
  }

  private createOrUpdate(individual: Individual, method, idString): Observable<Individual> {
    let headers: Headers = new Headers({ 'Content-Type': 'application/json' });
    let options: RequestOptions = new RequestOptions({ headers: headers });
    let record: any = {
      team_id: individual.team_id,
      login: individual.login,
      role: individual.role,
      enabled: individual.enabled,
      first_name: individual.first_name,
      last_name: individual.last_name,
      email: individual.email,
      phone_number: individual.phone_number,
      notification_type: individual.notification_type,
      refresh_interval: individual.refresh_interval,
      project_ids: individual.project_ids,
      selected_project_id: individual.selected_project_id
    };

    if (individual.password) {
      record['password'] = individual.password;
      record['password_confirmation'] = individual.password_confirmation;
    }
    return method.call(this.http, baseUrl + idString, {record: record}, options)
      .map((res: any) => res.json())
      .map((updatedIndividual: any) => {
        return new Individual(updatedIndividual);
      });
  }
}
