import { Injectable } from '@angular/core';
import { Http, Headers, RequestOptions } from '@angular/http';
declare var $: any;

import { Observable } from 'rxjs/Observable';
import { Story } from '../models/story';
import { StoryValue } from '../models/story-value';

const baseUrl = 'api/stories';

@Injectable()
export class StoriesService {
  constructor(private http: Http) { }

  getStories(queryString: string, page: number): Observable<Story[]> {
    return this.http.get(baseUrl + queryString + '&page=' + page)
      .map((res: any) => res.json())
      .map((stories: Array<any>) => {
        let result: Array<Story> = [];
        if (stories) {
          stories.forEach((story: any) => {
            result.push(
              new Story(story)
            );
          });
        }
        this.setRanks(result);
        return result;
      });
  }

  getStory(id: number): Observable<Story> {
    return this.http.get(baseUrl + '/' + id)
      .map((res: any) => res.json())
      .map((story: any) => {
        return new Story(story);
      });
  }
  
  getStoriesNumPages(queryString: string): Observable<number> {
    return this.http.get(baseUrl + '/num_pages' + queryString)
      .map((res: any) => res.json());
  }

  getEpics(status: any): Observable<Story[]> {
    return this.http.get(baseUrl + '/epics' + (status ? '?status_code=' + status : ''))
      .map((res: any) => res.json())
      .map((stories: Array<any>) => {
        let result: Array<Story> = [];
        if (stories) {
          stories.forEach((story: any) => {
            result.push(
              new Story(story)
            );
          });
        }
        return result;
      });
  }

  getChildren(story: Story, teamId?: any): Observable<Story[]> {
    return this.http.get(baseUrl + '?view_all=true&story_id=' + story.id + (teamId ? '&team_id=' + teamId : ''))
      .map((res: any) => res.json())
      .map((stories: Array<any>) => {
        let result: Array<Story> = [];
        if (stories) {
          stories.forEach((child: any) => {
            let childStory = new Story(child);
            childStory.epic = story;
            result.push(childStory);
          });
          story.stories = result;
          story.childrenLoaded = true;
        }
        return result;
      });
  }

  exportStories(queryString: string): void {
    $.fileDownload(baseUrl + '/export' + queryString);
  }

  create(story: Story): Observable<Story> {
    return this.createOrUpdate(story, this.http.post, '');
  }

  split(story: Story): Observable<Story> {
    return this.createOrUpdate(story, this.http.post, '/split/' + story.id);
  }

  update(story: any): Observable<Story> {
    return this.createOrUpdate(story, this.http.put, '/' + story.id);
  }

  delete(story: Story): Observable<any> {
    return this.http.delete(baseUrl + '/' + story.id);
  }

  setRanks(stories: Array<Story>): void {
    this.setRank(stories, 'rank', 'priority');
    this.setRank(stories, 'user_rank', 'user_priority');
  }

  private createOrUpdate(story: any, method, idString: string): Observable<Story> {
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });
    let record = {};
    if ('name' in story) {
      record['name'] = story.name;
    }
    if ('description' in story) {
      record['description'] = story.description;
    }
    if ('status_id' in story) {
      record['status_id'] = story.status_id;
    }
    if ('reason_blocked' in story) {
      record['reason_blocked'] = story.reason_blocked;
    }
    if ('project_id' in story) {
      record['project_id'] = story.project_id;
    }
    if ('story_id' in story) {
      record['story_id'] = story.story_id;
    }
    if ('release_id' in story) {
      record['release_id'] = story.release_id;
    }
    if ('iteration_id' in story) {
      record['iteration_id'] = story.iteration_id;
    }
    if ('team_id' in story) {
      record['team_id'] = story.team_id;
    }
    if ('individual_id' in story) {
      record['individual_id'] = story.individual_id;
    }
    if ('effort' in story) {
      record['effort'] = story.effort == null ? '' : ('' + story.effort);
    }
    if ('acceptance_criteria_string' in story) {
      record['acceptance_criteria'] = story.acceptance_criteria_string;
    }
    if ('is_public' in story) {
      record['is_public'] = story.is_public;
    }
    if (story.priority) {
      record['priority'] = story.priority;
    }
    if (story.story_values) {
      story.story_values.forEach((storyValue: StoryValue) => {
        record['custom_' + storyValue.story_attribute_id] = storyValue.value;
      });
    }
    return method.call(this.http, baseUrl + idString, {record: record}, options)
      .map((res: any) => res.json())
      .map((response: any) => {
        if (response.hasOwnProperty('record')) {
          return new Story(response.record);
        } else {
          return new Story(response);
        }
      });
  }

  private setRank(stories: Array<Story>, rankAttribute: string, priorityAttribute: string): void {
    let sorted: Array<Story> = stories.concat([]); // copy array
    sorted.sort(function(a: Story, b: Story): number {
      return a[priorityAttribute] - b[priorityAttribute];
    });
    let rank = 1;
    sorted.forEach((story: Story) => {
      if (story.status_code !== 3 && story[priorityAttribute]) { // not done
        story[rankAttribute] = rank;
        rank++;
      }
    });
  }
}
