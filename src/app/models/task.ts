import { Story } from './story';

export class Task {
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
  public estimate: number;
  public actual: number;
  public lead_time: number;
  public cycle_time: number;
  public story: Story;
  public added: boolean = false;
  public deleted: boolean = false;
  public previous_story_id: number;

  constructor(values: any) {
    this.id = values.id;
    this.name = values.name;
    this.description = values.description;
    this.effort = values.effort ? parseFloat(values.effort) : null;
    this.status_code = values.status_code;
    this.individual_id = values.individual_id;
    this.individual_name = values.individual_name;
    this.story_id = values.story_id;
    this.reason_blocked = values.reason_blocked;
    this.priority = parseFloat(values.priority);
    this.estimate = values.estimate ? parseFloat(values.estimate) : null;
    this.actual = values.actual ? parseFloat(values.actual) : null;
    this.lead_time = values.lead_time ? parseFloat(values.lead_time) : null;
    this.cycle_time = values.cycle_time ? parseFloat(values.cycle_time) : null;
    this.story = values.story;
  }

  get uniqueId(): string {
    return 'T' + this.id;
  }

  get size(): number {
    return null;
  }

  get toDo(): number {
      return this.effort;
  }

  isStory(): boolean {
    return false;
  }
}
