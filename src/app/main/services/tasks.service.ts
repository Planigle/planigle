import { Injectable } from '@angular/core';
import { Http, Headers, RequestOptions } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { Task } from '../models/task';

const baseUrl = 'api/stories/{story_id}/tasks';

@Injectable()
export class TasksService {
  constructor(private http: Http) { }

  create(task: Task): Observable<Task> {
    return this.createOrUpdate(task, this.http.post, '');
  }

  update(task: any): Observable<Task> {
    return this.createOrUpdate(task, this.http.put, '/' + task.id);
  }

  delete(task: Task): Observable<Task> {
    return this.http.delete(baseUrl.replace(new RegExp('{story_id}'), '' + task.story_id) + '/' + task.id)
      .map((res: any) => res.json())
      .map((response: any) => {
        if (response.hasOwnProperty('record')) {
          return new Task(response.record);
        } else {
          return new Task(response);
        }
      });
  }

  private createOrUpdate(task: any, method, idString): Observable<Task> {
    let headers: Headers = new Headers({ 'Content-Type': 'application/json' });
    let options: RequestOptions = new RequestOptions({ headers: headers });
    let record: any = {
      story_id: task.story_id,
    };
    if ('name' in task) {
      record['name'] = task.name;
    }
    if ('description' in task) {
      record['description'] = task.description;
    }
    if ('status_code' in task) {
      record['status_code'] = task.status_code;
    }
    if ('reason_blocked' in task) {
      record['reason_blocked'] = task.reason_blocked;
    }
    if ('individual_id' in task) {
      record['individual_id'] = task.individual_id;
    }
    if ('estimate' in task) {
      record['estimate'] = task.estimate == null ? '' : ('' + task.estimate);
    }
    if ('effort' in task) {
      record['effort'] = task.effort == null ? '' : ('' + task.effort);
    }
    if ('actual' in task) {
      record['actual'] = task.actual == null ? '' : ('' + task.actual);
    }
    if (task.priority) {
      record['priority'] = task.priority;
    }
    let story_id: number = task.previous_story_id ? task.previous_story_id : task.story_id;
    return method.call(this.http, baseUrl.replace(new RegExp('{story_id}'), '' + story_id) + idString, {record: record}, options)
      .map((res: any) => res.json())
      .map((updatedTask: any) => {
        return new Task(updatedTask);
      });
  }
}
