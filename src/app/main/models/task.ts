import { Work } from './work';
import { Story } from './story';

export class Task extends Work {
  public estimate: number;
  public actual: number;
  public story: Story;
  public previous_story_id: number;

  constructor(values: any) {
    super(values);
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

  updateParentStatus(): void {
    let status_code: number = this.status_code;
    let story: Story = this.story;
    if (status_code === 2) {
      if (story.status_code !== 2) {
        story.status_code = 2;
      }
    } else {
      let hasBlockedTask = false;
      story.tasks.forEach((task: Task) => {
        if (task.status_code === 2) {
          hasBlockedTask = true;
        }
      });
      if (story.status_code === 2 && !story.reason_blocked && !hasBlockedTask) {
        let hasInProgressTask = false;
        story.tasks.forEach((task: Task) => {
          if (task.status_code > 0) {
            hasInProgressTask = true;
          }
        });
        if (hasInProgressTask) {
          story.status_code = 1;
        } else {
          story.status_code = 0;
        }
      } else if (status_code > 0 && story.status_code === 0) {
        story.status_code = 1;
      }
    }
    story.updateParentStatus();
  }
}
