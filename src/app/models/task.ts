import { Work } from './work';
import { Story } from './story';

export class Task extends Work {
  public estimate: number;
  public actual: number;
  public story: Story;
  public previous_story_id: number;

  constructor(values: any) {
    super(values)
    this.estimate = values.estimate ? parseFloat(values.estimate) : null;
    this.actual = values.actual ? parseFloat(values.actual) : null;
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
