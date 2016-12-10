import { Team } from './team';

export class Project {
  public id: number;
  public name: string;
  public description: string;
  public survey_key: string;
  public survey_mode: number;
  public company_id: number;
  public track_actuals: boolean;
  public teams: Team[] = [];

  constructor(values: any) {
    this.id = values.id;
    this.name = values.name;
    this.description = values.description;
    this.survey_key = values.survey_key;
    this.survey_mode = values.survey_mode;
    this.company_id = values.company_id;
    this.track_actuals = values.track_actuals;

    if (values.teams) {
      values.teams.forEach((team) => {
        this.teams.push(new Team(team));
      });
    }
  }
}
