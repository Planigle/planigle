import { Injectable } from '@angular/core';
import { Http, Headers, RequestOptions } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { Task } from './task';

const baseUrl = 'api/stories/{story_id}/tasks';

@Injectable()
export class TasksService {
  constructor(private http: Http) { }

  update(task: Task): Observable<Task> {
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });
    let record = {
      name: task.name,
      description: task.description,
      status_code: task.status_code,
      reason_blocked: task.reason_blocked,
      individual_id: task.individual_id,
      estimate: task.estimate == null ? '' : ('' + task.estimate),
      effort: task.effort == null ? '' : ('' + task.effort)
    };
    return this.http.put(baseUrl.replace(new RegExp('{story_id}'), '' + task.story_id) + '/' + task.id, {record: record}, options)
      .map(res => res.json())
      .map((updatedTask: any) => {
        return new Task(updatedTask);
      });
  }
}
