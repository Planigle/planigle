import { Injectable } from '@angular/core';
import { Http, Headers, RequestOptions } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { Survey } from '../models/survey';
import { SurveyMapping } from '../models/survey-mapping';

const baseUrl = 'api/surveys';

@Injectable()
export class SurveysService {
  constructor(private http: Http) { }

  getSurveys(): Observable<Survey[]> {
    return this.http.get(baseUrl)
      .map(res => res.json())
      .map((surveys: Array<any>) => {
        let result: Array<Survey> = [];
        if (surveys) {
          surveys.forEach((survey: any) => {
            result.push(
              new Survey(survey)
            );
          });
        }
        return result;
      });
  }

  getMappings(survey: Survey): Observable<SurveyMapping[]> {
    return this.http.get(baseUrl + '/' + survey.id)
      .map(res => res.json())
      .map((surveyDetails: any) => {
        if (surveyDetails) {
          survey.addSurveyMappings(surveyDetails.survey_mappings);
        }
        return survey.surveyMappings;
      });
  }

  update(survey: Survey): Observable<Survey> {
    let headers: Headers = new Headers({ 'Content-Type': 'application/json' });
    let options: RequestOptions = new RequestOptions({ headers: headers });
    let record: any = {
      excluded: survey.excluded
    };
    return this.http.put.call(this.http, baseUrl + '/' + survey.id, {record: record}, options)
      .map((res: any) => res.json())
      .map((updatedSurvey: any) => {
        return new Survey(updatedSurvey);
      });
  }
}
