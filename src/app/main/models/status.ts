export class Status {
  public id: number;
  public project_id: number;
  public name: string;
  public ordering: number;
  public status_code: number;
  public applies_to_stories: boolean;
  public applies_to_tasks: boolean;

  constructor(values: any) {
    this.id = values.id;
    this.project_id = values.project_id;
    this.name = values.name;
    this.ordering = values.ordering;
    this.status_code = values.status_code;
    this.applies_to_stories = values.applies_to_stories;
    this.applies_to_tasks = values.applies_to_tasks;
  }
}
