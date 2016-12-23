export class Team {
  public id: number;
  public name: string;
  public description: string;
  public project_id: number;

  constructor(values: any) {
    this.id = values.id;
    this.name = values.name;
    this.description = values.description;
    this.project_id = values.project_id;
  }
}
