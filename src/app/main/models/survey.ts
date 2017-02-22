import { ReflectiveInjector } from '@angular/core';
import { DatesService } from '../services/dates.service';
import { SurveyMapping } from './survey-mapping';

export class Survey {
  id: number;
  email: string;
  excluded: boolean;
  updated_at: Date;
  name: String;
  company: String;
  survey_key: String;
  surveyMappings: SurveyMapping[];

  constructor(values: any) {
    this.id = values.id;
    this.email = values.email;
    this.excluded = values.excluded;
    this.updated_at = this.getDatesService().parseDateTime(values.updated_at);
    this.name = values.name;
    this.company = values.company;
    this.survey_key = values.survey_key;
  }

  addSurveyMappings(mappings: any[]): void {
    let surveyMappings: SurveyMapping[] = [];
    mappings.forEach((mapping: any) => {
      surveyMappings.push(new SurveyMapping(mapping));
    });
    this.surveyMappings = surveyMappings;
  }

  get updatedString(): string {
    return this.getDatesService().getDateTimeString(this.updated_at);
  }

  private getDatesService(): DatesService {
    return ReflectiveInjector.resolveAndCreate([DatesService]).get(DatesService);
  }
}
