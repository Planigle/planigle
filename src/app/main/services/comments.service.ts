import { Injectable } from '@angular/core';
import { Http, Headers, RequestOptions } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { Story } from '../models/story';
import { Comment } from '../models/comment';

const baseUrl = 'api/stories/{story_id}/comments';

@Injectable()
export class CommentsService {
  constructor(private http: Http) { }

  create(comment: Comment): Observable<Comment> {
    return this.createOrUpdate(comment, this.http.post, '');
  }

  update(comment: any): Observable<Comment> {
    return this.createOrUpdate(comment, this.http.put, '/' + comment.id);
  }

  delete(comment: Comment): Observable<Comment> {
    return this.http.delete(baseUrl.replace(new RegExp('{story_id}'), '' + comment.story_id) + '/' + comment.id)
      .map((res: any) => res.json())
      .map((response: any) => {
        if (response.hasOwnProperty('record')) {
          return new Comment(response.record);
        } else {
          return new Comment(response);
        }
      });
  }

  private createOrUpdate(comment: any, method, idString): Observable<Comment> {
    let headers: Headers = new Headers({ 'Content-Type': 'application/json' });
    let options: RequestOptions = new RequestOptions({ headers: headers });
    let record: any = {
      story_id: comment.story_id,
      individual_id: comment.individual_id,
      message: comment.message
    };
    return method.call(this.http, baseUrl.replace(new RegExp('{story_id}'), '' + comment.story_id) + idString, {record: record}, options)
      .map((res: any) => res.json())
      .map((updatedComment: any) => {
        return new Comment(updatedComment);
      });
  }
}
