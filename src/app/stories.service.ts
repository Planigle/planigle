import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { Story } from './story';

const baseUrl = 'api/stories';

@Injectable()
export class StoriesService {
  constructor(private http: Http) { }

  getStories(release, iteration, team, individual, status): Observable<Story[]> {
    let queryString = '?';
    if (release !== 'All') {
      queryString += 'release_id=' + release + '&';
    }
    if (iteration !== 'All') {
      queryString += 'iteration_id=' + iteration + '&';
    }
    if (team !== 'All') {
      queryString += 'team_id=' + team + '&';
    }
    if (individual !== 'All') {
      queryString += 'individual_id=' + individual + '&';
    }
    if (status !== 'All') {
      queryString += 'status_code=' + status + '&';
    }
    queryString = queryString.substring(0, queryString.length - 1);
    return this.http.get(baseUrl + queryString)
      .map(res => res.json())
      .map((stories: Array<any>) => {
        let result: Array<Story> = [];
        if (stories) {
          stories.forEach((story) => {
            result.push(
              new Story(story)
            );
          });
        }
        this.setRank(result, 'rank', 'priority');
        this.setRank(result, 'user_rank', 'user_priority');
        return result;
      });
  }

  private setRank(stories: Array<Story>, rankAttribute: string, priorityAttribute: string) {
    let sorted: Array<Story> = stories.concat([]); // copy array
    sorted.sort(function(a: Story, b: Story): number {
      return a[priorityAttribute] - b[priorityAttribute];
    });
    let rank = 1;
    sorted.forEach((story) => {
      if (story.status_code !== 3 && story[priorityAttribute]) { // not done
        story[rankAttribute] = rank;
        rank++;
      }
    });
  }
}
