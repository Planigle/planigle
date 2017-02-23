import { Injectable } from '@angular/core';
import { Http, Headers, RequestOptions } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { Survey } from '../models/survey';
import { SurveyMapping } from '../models/survey-mapping';

const baseUrl = 'api/surveys';

@Injectable()
export class SurveysService {
  constructor(private http: Http) { }

  getSurvey(surveyKey: string) {
    let survey = new Survey({
      survey_key: surveyKey
    });
    return this.http.get(baseUrl + '/new?survey_key=' + surveyKey)
      .map(res => res.json())
      .map((surveyDetails: any[]) => {
        if (surveyDetails) {
          survey.addSurveyMappings(surveyDetails);
        }
        return survey;
      });
  }

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

  submit(survey: Survey): Observable<string> {
    let headers: Headers = new Headers({ 'Content-Type': 'application/json' });
    let options: RequestOptions = new RequestOptions({ headers: headers });
    let stories = [];
    survey.surveyMappings.forEach((mapping: SurveyMapping) => {
      if (mapping.story_id < 0) {
        stories.push(mapping.name + ',' + mapping.description);
      } else {
        stories.push(mapping.story_id);
      }
    });
    let record: any = {
      survey_key: survey.survey_key,
      name: survey.name,
      company: survey.company,
      email: survey.email,
      stories: stories
    };
    return this.http.post.call(this.http, baseUrl + '?survey_key=' + survey.survey_key, {record: record}, options)
      .map((res: any) => res.json())
      .map((response: any) => {
        return response.message;
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
