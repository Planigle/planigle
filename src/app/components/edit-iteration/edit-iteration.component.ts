import { Component, OnChanges, Input, Output, EventEmitter } from '@angular/core';
import { IterationsService } from '../../services/iterations.service';
import { ErrorService } from '../../services/error.service';
import { Iteration } from '../../models/iteration';
import { Individual } from '../../models/individual';
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-edit-iteration',
  templateUrl: './edit-iteration.component.html',
  styleUrls: ['./edit-iteration.component.css'],
  providers: [IterationsService]
})
export class EditIterationComponent implements OnChanges {
  @Input() iteration: Iteration;
  @Input() me: Individual;
  @Output() closed: EventEmitter<any> = new EventEmitter();

  public model: Iteration;
  public error: String;

  constructor(
    private iterationsService: IterationsService,
    private errorService: ErrorService) {
  }

  ngOnChanges(changes): void {
    if (changes.iteration) {
      this.model = new Iteration(this.iteration);
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
    let method: any = this.model.id ? this.iterationsService.update : this.iterationsService.create;
    method.call(this.iterationsService, this.model).subscribe(
      (iteration: Iteration) => {
        if (!this.iteration.id) {
          this.iteration.added = true;
        }
        this.iteration.id = iteration.id;
        this.iteration.name = iteration.name;
        this.iteration.start = iteration.start;
        this.iteration.finish = iteration.finish;
        this.iteration.notable = iteration.notable;
        this.iteration.retrospective_results = iteration.retrospective_results;
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
