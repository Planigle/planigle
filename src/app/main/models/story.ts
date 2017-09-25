import { AcceptanceCriterium } from './acceptance-criterium';
import { Work } from './work';
import { Task } from './task';
import { Comment } from './comment';
import { StoryValue } from './story-value';

export class Story extends Work {
  public iteration_id: number;
  public iteration_name: string;
  public project_id; number;
  public is_public; boolean;
  public user_priority: number;
  public release_id: number;
  public release_name: string;
  public team_id: number;
  public team_name: string;
  public rank: number;
  public user_rank: number;
  public expanded: boolean = false;
  public epic_name: string;
  public acceptance_criteria: AcceptanceCriterium[] = [];
  public tasks: Task[] = [];
  public comments: Comment[] = [];
  public story_values: StoryValue[] = [];
  public stories: Story[] = [];
  public epic: Story;
  public childrenLoaded: boolean = true;
  public split: Story;

  constructor(values: any) {
    super(values);
    this.iteration_id = values.iteration_id;
    this.iteration_name = values.iteration_name;
    this.project_id = values.project_id;
    this.is_public = values.is_public;
    this.user_priority = parseFloat(values.user_priority);
    this.release_id = values.release_id;
    this.release_name = values.release_name;
    this.team_id = values.team_id;
    this.team_name = values.team_name;
    this.epic_name = values.epic_name;
    let story = this;
    let criteria = values.criteria ? values.criteria : values.acceptance_criteria;
    if (criteria) {
      criteria.forEach((criterium: any) => {
        this.acceptance_criteria.push(new AcceptanceCriterium(criterium));
      });
    }
    if (values.filtered_tasks) {
      values.filtered_tasks.forEach((task: any) => {
        task.story = story;
        this.tasks.push(new Task(task));
      });
    }
    if (values.comments) {
      values.comments.forEach((comment: any) => {
        this.comments.push(new Comment(comment));
      });
    }
    if (values.story_values) {
      values.story_values.forEach((storyValue: any) => {
        this.story_values.push(new StoryValue(storyValue));
      });
    }
    if (values.filtered_stories) {
      if (values.filtered_stories.length > 0) {
        this.childrenLoaded = false;
      }
      values.filtered_stories.forEach((child: any) => {
        let childStory: Story = new Story(child);
        childStory.epic = this;
        this.stories.push(childStory);
      });
    }
  }

  isEpic(): boolean {
    return this.tasks.length === 0;
  }

  canAddChildren(): boolean {
    return (this.epic == null || this.epic.childrenLoaded) && this.isEpic();
  }

  get uniqueId(): string {
    return 'S' + this.id;
  }

  get size(): number {
    return this.effort;
  }

  get toDo(): number {
    return this.getTotal('toDo');
  }

  get estimate(): number {
    return this.getTotal('estimate');
  }

  get actual(): number {
    return this.getTotal('actual');
  }

  get acceptance_criteria_string(): string {
    let result = '';
    let first = true;
    this.acceptance_criteria.forEach((criterium: AcceptanceCriterium) => {
      if (first) {
        first = false;
      } else {
        result += '\n';
      }
      if (this.acceptance_criteria.length > 1) {
        result += '*';
      }
      result += criterium.description;
      if (criterium.isDone()) {
        result += ' (Done)';
      }
    });
    return result;
  }

  isStory(): boolean {
    return true;
  }

  private getTotal(field: string): number {
    let total = 0;
    this.tasks.forEach((task: Task) => {
      if (task[field]) {
        total += task[field];
      }
    });

    // Round to one hundredths place scaling to account for floating point issues
    return total === 0 ? null : (Math.round((total + 0.00001) * 100) / 100);
  }

  hasLoaded(): boolean {
    return this.childrenLoaded;
  }
}
