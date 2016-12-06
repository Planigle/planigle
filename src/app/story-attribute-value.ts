export class StoryAttributeValue {
  public id: number;
  public story_attribute_id: number;
  public release_id: number;
  public value: string;

  constructor(values: any) {
    this.id = values.id;
    this.story_attribute_id = values.story_attribute_id;
    this.release_id = values.release_id;
    this.value = values.value;
  }
}
