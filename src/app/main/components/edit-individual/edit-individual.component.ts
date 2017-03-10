import { Component, OnChanges, Input, Output, EventEmitter } from '@angular/core';
import { Router } from '@angular/router';
import {IMultiSelectOption} from 'angular-2-dropdown-multiselect/src/multiselect-dropdown';
import { IndividualsService } from '../../services/individuals.service';
import { ErrorService } from '../../services/error.service';
import { Individual } from '../../models/individual';
import { Team } from '../../models/team';
import { Project } from '../../models/project';
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-edit-individual',
  templateUrl: './edit-individual.component.html',
  styleUrls: ['./edit-individual.component.css']
})
export class EditIndividualComponent implements OnChanges {
  @Input() individual: Individual;
  @Input() me: Individual;
  @Input() projects: IMultiSelectOption[];
  @Input() teams: Team[];
  @Output() closed: EventEmitter<any> = new EventEmitter();

  public model: Individual;
  public projectTeams: Team[];
  public error: String;

  constructor(
    private router: Router,
    private individualsService: IndividualsService,
    private errorService: ErrorService) {
  }

  ngOnChanges(changes): void {
    if (changes.individual) {
      this.model = new Individual(this.individual);
      this.updateProject();
      setTimeout(() => $('input[autofocus=""]').focus(), 0);
    }
  }

  isNew(): boolean {
    return this.model.id == null;
  }

  updateProject(): void {
    let self: EditIndividualComponent = this;
    let projectTeams: Team[] = [];
    let hasTeam = false;
    this.projects.forEach((project:  Project) => {
      for (let i = 0; i < self.model.project_ids.length; i++) {
        if (project.id === self.model.project_ids[i]) {
          project.teams.forEach((team: Team) => {
            projectTeams.push(team);
            if (team.id === this.model.team_id) {
              hasTeam = true;
            }
          });
        }
      }
    });
    this.projectTeams = projectTeams;
    if (!hasTeam) {
      this.model.team_id = null;
    }
  }

  projectNames(): string {
    let names = [];
    this.projects.forEach((project) => {
      this.model.project_ids.forEach((project_id => {
        if (project.id === project_id) {
          names.push(project.name);
        }
      }));
    });
    return names.join(', ');
  }

  updateTeam(): void {
    if (String(this.model.team_id) === 'null') {
      this.model.team_id = null;
    } else {
      this.model.team_id = parseInt(String(this.model.team_id), 10);
    }
  }

  canSave(form: any): boolean {
    return form.form.valid && this.canUpdate();
  }

  canUpdate(): boolean {
    return this.me.id === this.individual.id || this.me.canChangeRelease();
  }

  ok(form): void {
    if (this.canSave(form)) {
      this.saveModel(FinishedEditing.Save, null);
    }
  }

  addAnother(form): void {
    if (this.canSave(form)) {
      this.saveModel(FinishedEditing.AddAnother, form);
    }
  }

  cancel(): void {
    this.closed.emit({value: FinishedEditing.Cancel});
  }

  private saveModel(result: FinishedEditing, form: any): void {
    let method: any = this.model.id ? this.individualsService.update : this.individualsService.create;
    method.call(this.individualsService, this.model).subscribe(
      (individual: Individual) => {
        this.individual.project_ids = individual.project_ids;
        this.individual.team_id = individual.team_id;
        this.individual.team_name = individual.team_name;
        this.individual.login = individual.login;
        this.individual.role = individual.role;
        this.individual.enabled = individual.enabled;
        this.individual.first_name = individual.first_name;
        this.individual.first_name = individual.first_name;
        this.individual.last_name = individual.last_name;
        this.individual.email = individual.email;
        this.individual.phone_number = individual.phone_number;
        this.individual.notification_type = individual.notification_type;
        this.individual.refresh_interval = individual.refresh_interval;
        if (form) {
          form.reset();
          $('input[name="login"]').focus();
        }
        this.closed.emit({value: result});
      },
      (err: any) => {
        this.error = this.errorService.getError(err);
      }
    );
  }

  viewChanges(): void {
    this.router.navigate(['changes', {type: 'Individual', id: this.model.id}]);
  }
}
