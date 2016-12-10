import { Task } from './task';
import { StoryValue } from './story-value';

export class Story {
  public id: number;
  public name: string;
  public description: string;
  public effort: number;
  public status_code: number;
  public priority: number;
  public iteration_id: number;
  public iteration_name: string;
  public individual_id: number;
  public individual_name: string;
  public project_id; number;
  public is_public; boolean;
  public user_priority: number;
  public release_id: number;
  public release_name: string;
  public team_id: number;
  public team_name: string;
  public reason_blocked: string;
  public story_id: number;
  public done_at: string;
  public lead_time: number;
  public cycle_time: number;
  public rank: number;
  public user_rank: number;
  public acceptance_criteria: string;
  public expanded: boolean = false;
  public tasks: Task[]= [];
  public storyValues: StoryValue[] = [];

  constructor(values: any) {
    this.id = values.id;
    this.name = values.name;
    this.description = values.description;
    this.effort = values.effort ? parseFloat(values.effort) : null;
    this.status_code = values.status_code;
    this.priority = parseFloat(values.priority);
    this.iteration_id = values.iteration_id;
    this.iteration_name = values.iteration_name;
    this.individual_id = values.individual_id;
    this.individual_name = values.individual_name;
    this.project_id = values.project_id;
    this.is_public = values.is_public;
    this.user_priority = parseFloat(values.user_priority);
    this.release_id = values.release_id;
    this.release_name = values.release_name;
    this.team_id = values.team_id;
    this.team_name = values.team_name;
    this.reason_blocked = values.reason_blocked;
    this.story_id = values.story_id;
    this.done_at = values.done_at;
    this.lead_time = values.lead_time ? parseFloat(values.lead_time) : null;
    this.cycle_time = values.cycle_time ? parseFloat(values.cycle_time) : null;
    this.acceptance_criteria = values.acceptance_criteria;
    let story = this;
    if (values.filtered_tasks) {
      values.filtered_tasks.forEach((task) => {
        task.story = story;
        this.tasks.push(new Task(task));
      });
    }
    if (values.story_values) {
      values.story_values.forEach((storyValue) => {
        this.storyValues.push(new StoryValue(storyValue));
      });
    }
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
}
