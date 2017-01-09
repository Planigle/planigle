import { Organization } from './organization';
import { Company } from './company';
import { Team } from './team';

export class Project extends Organization {
  public description: string;
  public survey_key: string;
  public survey_mode: number;
  public company_id: number;
  public company: Company;
  public track_actuals: boolean;
  public teams: Team[] = [];

  constructor(values: any) {
    super(values);
    this.description = values.description;
    this.survey_key = values.survey_key;
    this.survey_mode = values.survey_mode;
    this.company_id = values.company_id;
    this.track_actuals = values.track_actuals;

    if (values.teams) {
      values.teams.forEach((team) => {
        let newTeam: Team = new Team(team);
        newTeam.project = this;
        this.teams.push(newTeam);
      });
    }
  }
  
  get uniqueId(): string {
    return 'P' + this.id;
  }
  
  isProject(): boolean {
    return true;
  }
}
