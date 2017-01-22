import { Injectable } from '@angular/core';
import { Http, Headers, RequestOptions } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { Project } from '../models/project';

const baseUrl = 'api/projects';

@Injectable()
export class ProjectsService {
  constructor(private http: Http) { }

  getProjects(): Observable<Project[]> {
    return this.http.get(baseUrl)
      .map(res => res.json())
      .map((projects: Array<any>) => {
        let result: Array<Project> = [];
        if (projects) {
          projects.forEach((project: any) => {
            result.push(
              new Project(project)
            );
          });
        }
        return result;
      });
  }

  create(project: Project): Observable<Project> {
    return this.createOrUpdate(project, this.http.post, '');
  }

  update(project: Project): Observable<Project> {
    return this.createOrUpdate(project, this.http.put, '/' + project.id);
  }

  delete(project: Project): Observable<Project> {
    return this.http.delete(baseUrl + '/' + project.id)
      .map((res: any) => res.json())
      .map((response: any) => {
        if (response.hasOwnProperty('record')) {
          return new Project(response.record);
        } else {
          return new Project(response);
        }
      });
  }

  private createOrUpdate(project: Project, method, idString): Observable<Project> {
    let headers: Headers = new Headers({ 'Content-Type': 'application/json' });
    let options: RequestOptions = new RequestOptions({ headers: headers });
    let record: any = {
      name: project.name,
      description: project.description,
      survey_mode: project.survey_mode,
      track_actuals: project.track_actuals
    };
    return method.call(this.http, baseUrl + idString, {record: record}, options)
      .map((res: any) => res.json())
      .map((updatedProject: any) => {
        return new Project(updatedProject);
      });
  }
}
