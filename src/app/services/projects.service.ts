import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
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
}
