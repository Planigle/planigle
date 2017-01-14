import { Component, OnChanges, Input, Output, EventEmitter } from '@angular/core';
import { TeamsService } from '../../services/teams.service';
import { ErrorService } from '../../services/error.service';
import { Team } from '../../models/team';
import { Individual } from '../../models/individual';
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-edit-team',
  templateUrl: './edit-team.component.html',
  styleUrls: ['./edit-team.component.css'],
  providers: [TeamsService]
})
export class EditTeamComponent implements OnChanges {
  @Input() team: Team;
  @Input() me: Individual;
  @Output() closed: EventEmitter<any> = new EventEmitter();

  public model: Team;
  public error: String;

  constructor(
    private teamsService: TeamsService,
    private errorService: ErrorService) {
  }

  ngOnChanges(changes): void {
    if (changes.team) {
      this.model = new Team(this.team);
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
    let method: any = this.model.id ? this.teamsService.update : this.teamsService.create;
    method.call(this.teamsService, this.model).subscribe(
      (team: Team) => {
        if (!this.team.id) {
          this.team.added = true;
        }
        this.team.id = team.id;
        this.team.name = team.name;
        this.team.description = team.description;
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
