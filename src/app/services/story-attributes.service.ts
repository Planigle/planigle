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
  
  create(storyAttribute: StoryAttribute): Observable<StoryAttribute> {
    return this.createOrUpdate(storyAttribute, this.http.post, '');
  }

  update(storyAttribute: any): Observable<StoryAttribute> {
    return this.createOrUpdate(storyAttribute, this.http.put, '/' + storyAttribute.id);
  }

  delete(storyAttribute: StoryAttribute): Observable<StoryAttribute> {
    return this.http.delete(baseUrl + '/' + storyAttribute.id)
      .map((res: any) => res.json())
      .map((response: any) => {
        if (response.hasOwnProperty('record')) {
          return new StoryAttribute(response.record);
        } else {
          return new StoryAttribute(response);
        }
      });
  }

  private createOrUpdate(storyAttribute: StoryAttribute, method, idString): Observable<StoryAttribute> {
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });
    let record = {
      name: storyAttribute.name,
      value_type: storyAttribute.value_type,
      width: storyAttribute.width,
      show: storyAttribute.show,
      values: storyAttribute.values()
    };
    if(storyAttribute.ordering) {
      record['ordering'] = storyAttribute.ordering
    }
    return method.call(this.http,baseUrl + idString, {record: record}, options)
      .map((res: any) => res.json())
      .map((updatedAttribute: any) => {
        return new StoryAttribute(updatedAttribute);
      });
  }
}
