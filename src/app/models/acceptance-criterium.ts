export class AcceptanceCriterium {
  id: number;
  description: string;
  status_code: number = 0;
  story_id: number;
  priority: number;

  constructor(values: any) {
    this.id = values.id;
    this.description = values.description;
    this.status_code = values.status_code;
    this.story_id = values.story_id;
    this.priority = parseFloat(values.priority);
  }

  isDone(): boolean {
    return this.status_code !== 0;
  }

  markNotDone(): void {
    this.status_code = 0;
  }

  markDone(): void {
    this.status_code = 1;
  }
}
