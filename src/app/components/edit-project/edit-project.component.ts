import { Component, OnChanges, Input, Output, EventEmitter } from '@angular/core';
import { ProjectsService } from '../../services/projects.service';
import { ErrorService } from '../../services/error.service';
import { Project } from '../../models/project';
import { Individual } from '../../models/individual';
import { FinishedEditing } from '../../models/finished-editing'
declare var $: any;

@Component({
  selector: 'app-edit-project',
  templateUrl: './edit-project.component.html',
  styleUrls: ['./edit-project.component.css'],
  providers: [ProjectsService]
})
export class EditProjectComponent {
  @Input() project: Project;
  @Input() me: Individual;
  @Output() closed: EventEmitter<any> = new EventEmitter();

  public model: Project;
  public error: String;

  constructor(
    private projectsService: ProjectsService, 
    private errorService: ErrorService) {
  }

  ngOnChanges(changes): void {
    if (changes.project) {
      this.model = new Project(this.project);
      setTimeout(() => $('input[autofocus=""]').focus(), 0);
    }
  }

  isNew(): boolean {
    return this.model.id == null;
  }
  
  canSave(form: any): boolean {
    return form.form.valid && this.me.canChangeRelease();
  }
  
  ok(): void {
    this.saveModel(FinishedEditing.Save, null);
  }
  
  cancel(): void {
    this.closed.emit({value: FinishedEditing.Cancel});
  }
  
  addAnother(form): void {
    this.saveModel(FinishedEditing.AddAnother, form);
  }
  
  private saveModel(result: FinishedEditing, form: any): void {
    let method: any = this.model.id ? this.projectsService.update : this.projectsService.create;
    method.call(this.projectsService, this.model).subscribe(
      (project: Project) => {
        if (!this.project.id) {
          this.project.added = true;
        }
        this.project.id = project.id;
        this.project.name = project.name;
        this.project.description = project.description;
        this.project.track_actuals = project.track_actuals;
        if (form) {
          form.reset();
          $('input[name="name"]').focus();
        }
        this.closed.emit({value: result});
      },
      (err: any) => {
        this.error = this.errorService.getError(err);
      }
    );
  }
}
