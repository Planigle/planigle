export class StoryValue {
  public id: number;
  public story_id: number;
  public story_attribute_id: number;
  public value: string;

  constructor(values: any) {
    this.id = values.id;
    this.story_id = values.story_id;
    this.story_attribute_id = values.story_attribute_id;
    this.value = values.value;
  }
}
