import { StoryAttributeValue } from './story-attribute-value';
import { StoryValue } from './story-value';
import { ChooseStatusComponent } from '../components/choose-status/choose-status.component';

export class StoryAttribute {
  public id: number;
  public project_id: number;
  public name: string;
  public value_type: number;
  public is_custom: boolean;
  public width: number;
  public ordering: number;
  public show: boolean;
  public storyAttributeValues: StoryAttributeValue[] = [];

  private mappings: any = {
    'Id': 'id',
    'Epic': 'story_id',
    'Name': 'name',
    'Description': 'description',
    'Acceptance Criteria': 'acceptance_criteria_string',
    'Release': 'release_name',
    'Iteration': 'iteration_name',
    'Team': 'team_name',
    'Project': 'project_id',
    'Owner': 'individual_name',
    'Public': 'is_public',
    'Rank': 'rank',
    'User Rank': 'user_rank',
    'Lead Time': 'lead_time',
    'Cycle Time': 'cycle_time',
    'Estimate': 'estimate',
    'Actual': 'actual',
    'To Do': 'toDo',
    'Size': 'size'
  };

  constructor(values: any) {
    this.id = values.id;
    this.project_id = values.project_id;
    this.name = values.name;
    this.value_type = values.value_type;
    this.is_custom = values.is_custom;
    this.width = values.width;
    this.ordering = parseFloat(values.ordering);
    this.show = values.show;
    values.story_attribute_values.forEach((storyAttributeValue) => {
      this.storyAttributeValues.push(new StoryAttributeValue(storyAttributeValue));
    });
    this.storyAttributeValues.sort((v1: StoryAttributeValue, v2: StoryAttributeValue) => {
      if (v1.value < v2.value) {
        return -1;
      }
      if (v2.value < v1.value) {
        return 1;
      }
      return 0;
    });
  }

  getFieldName(): string {
    let fieldName: string = this.mappings[this.name];
    return fieldName == null ? '' : fieldName;
  }

  getter(): any {
    if (this.is_custom || this.storyAttributeValues.length > 0) {
      return this.getValue;
    }
    switch (this.name) {
      case 'Status':
        return this.getStatus;
      default:
        return null;
    }
  }

  getStatus(params: any): string {
    switch (params.data.status_code) {
      case 0: return 'Not Started';
      case 1: return 'In Progress';
      case 2: return 'Blocked';
      case 3: return 'Done';
    }
  }

  getSize(params: any): number {
    let object: any = params.data;
    return object.getSize();
  }

  getToDo(params: any): number {
    let object: any = params.data;
    return object.getToDo();
  }

  getValue(params: any): string {
    let object: any = params.data;
    let storyAttribute = params.colDef.storyAttribute;
    let result = null;
    if (object.story_values) {
      if(storyAttribute.storyAttributeValues.length > 0) {
        storyAttribute.storyAttributeValues.forEach((value: StoryAttributeValue) => {
          object.story_values.forEach((storyValue: StoryValue) => {
            if (storyValue.story_attribute_id === storyAttribute.id && parseFloat(storyValue.value) === value.id) {
              result = value.value;
            }
          });
        });
      } else {
        object.story_values.forEach((storyValue: StoryValue) => {
          if (storyValue.story_attribute_id === storyAttribute.id) {
            result = storyValue.value;
          }
        });
      }
    }
    return result;
  }

  getTooltip(): string {
    switch (this.name) {
      case 'Name':
        return 'description';
      case 'Description':
        return 'description';
      case 'Acceptance Criteria':
        return 'acceptance_criteria_string';
      default:
        return null;
    }
  }

  getCellRenderer(): any {
    switch (this.name) {
      case 'Status':
        return ChooseStatusComponent;
      default:
        return null;
    }
  }

  getValuesForRelease(release_id: number): StoryAttributeValue[] {
    let values: StoryAttributeValue[] = [];
    this.storyAttributeValues.forEach((storyAttributeValue: StoryAttributeValue) => {
      if (storyAttributeValue.release_id === release_id) {
        values.push(storyAttributeValue);
      }
    });
    return values;
  }
}
