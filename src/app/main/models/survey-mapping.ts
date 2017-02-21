export class SurveyMapping {
  story_id: number;
  priority: number;
  name: string;
  description: string;
  normalized_priority: number;

  constructor(values: any) {
    this.story_id = values.story_id;
    this.priority = values.priority;
    this.name = values.name;
    this.description = values.description;
    this.normalized_priority = values.normalized_priority;
  }
}
