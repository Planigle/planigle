import { Organization } from './organization';
import { Project } from './project';

export class Team extends Organization {
  public description: string;
  public project: Project;
  public project_id: number;

  constructor(values: any) {
    super(values);
    this.description = values.description;
    this.project = values.project;
    this.project_id = values.project_id;
  }

  get uniqueId(): string {
    return 'T' + this.id;
  }

  isTeam(): boolean {
    return true;
  }
}
