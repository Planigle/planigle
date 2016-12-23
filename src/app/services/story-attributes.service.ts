import { Injectable } from '@angular/core';
import { Http, Headers, RequestOptions } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { StoryAttribute } from '../models/story-attribute';

const baseUrl = 'api/story_attributes';

@Injectable()
export class StoryAttributesService {
  constructor(private http: Http) { }

  getStoryAttributes(): Observable<StoryAttribute[]> {
    return this.http.get(baseUrl)
      .map((res: any) => res.json())
      .map((storyAttributes: Array<any>) => {
        let result: Array<StoryAttribute> = [];
        if (storyAttributes) {
          storyAttributes.forEach((storyAttribute) => {
            result.push(
              new StoryAttribute(storyAttribute)
            );
          });
        }
        return result;
      });
  }

  update(storyAttribute: StoryAttribute): Observable<StoryAttribute> {
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });
    let record = {
      width: storyAttribute.width,
      ordering: storyAttribute.ordering,
      show: storyAttribute.show
    };
    return this.http.put(baseUrl + '/' + storyAttribute.id, {record: record}, options)
      .map((res: any) => res.json())
      .map((updatedAttribute: any) => {
        return new StoryAttribute(updatedAttribute);
      });
  }
}
