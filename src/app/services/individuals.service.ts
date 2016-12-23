import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
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
}
