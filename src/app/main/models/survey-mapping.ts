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

  get descriptionFirstLine(): string {
    if (this.description) {
      let index: number = this.description.indexOf('\r');
      if (index > -1) {
        return this.description.substring(0, index);
      } else {
        return this.description;
      }
    } else {
      return this.description;
    }
  }
}
