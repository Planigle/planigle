import { Component, OnChanges, Input, Output, EventEmitter } from '@angular/core';
import { Router } from '@angular/router';
import { IndividualsService } from '../../services/individuals.service';
import { ErrorService } from '../../services/error.service';
import { Individual } from '../../models/individual';
import { Team } from '../../models/team';
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
  @Input() teams: Team[];
  @Output() closed: EventEmitter<any> = new EventEmitter();

  public model: Individual;
  public error: String;

  constructor(
    private router: Router,
    private individualsService: IndividualsService,
    private errorService: ErrorService) {
  }

  ngOnChanges(changes): void {
    if (changes.individual) {
      this.model = new Individual(this.individual);
      setTimeout(() => $('input[autofocus=""]').focus(), 0);
    }
  }

  isNew(): boolean {
    return this.model.id == null;
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

  ok(): void {
    this.saveModel(FinishedEditing.Save, null);
  }

  addAnother(form): void {
    this.saveModel(FinishedEditing.AddAnother, form);
  }

  cancel(): void {
    this.closed.emit({value: FinishedEditing.Cancel});
  }

  private saveModel(result: FinishedEditing, form: any): void {
    this.individualsService.update(this.model).subscribe(
      (individual: Individual) => {
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
