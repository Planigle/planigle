export abstract class Work {
  public id: number;
  public name: string;
  public description: string;
  public effort: number;
  public status_code: number;
  public individual_id: number;
  public individual_name: string;
  public story_id; number;
  public reason_blocked: string;
  public priority: number;
  public lead_time: number;
  public cycle_time: number;
  public added: boolean = false;
  public deleted: boolean = false;
  
  constructor(values: any) {
    this.id = values.id;
    this.name = values.name;
    this.description = values.description;
    this.effort = values.effort ? parseFloat(values.effort) : null;
    this.status_code = values.status_code;
    this.priority = parseFloat(values.priority);
    this.individual_id = values.individual_id;
    this.individual_name = values.individual_name;
    this.reason_blocked = values.reason_blocked;
    this.story_id = values.story_id;
    this.lead_time = values.lead_time ? parseFloat(values.lead_time) : null;
    this.cycle_time = values.cycle_time ? parseFloat(values.cycle_time) : null;
  }
  
  abstract get uniqueId(): string;
  abstract get size(): number;
  abstract get toDo(): number;
  abstract isStory(): boolean;
}
