import { Component, OnChanges, Input, Output, EventEmitter } from '@angular/core';
import { ReleasesService } from '../../services/releases.service';
import { ErrorService } from '../../services/error.service';
import { Release } from '../../models/release';
import { Individual } from '../../models/individual';
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-edit-release',
  templateUrl: './edit-release.component.html',
  styleUrls: ['./edit-release.component.css'],
  providers: [ReleasesService]
})
export class EditReleaseComponent implements OnChanges {
  @Input() release: Release;
  @Input() me: Individual;
  @Output() closed: EventEmitter<any> = new EventEmitter();

  public model: Release;
  public error: String;

  constructor(private releasesService: ReleasesService, private errorService: ErrorService) {
  }

  ngOnChanges(changes): void {
    if (changes.release) {
      this.model = new Release(this.release);
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
    let method: any = this.model.id ? this.releasesService.update : this.releasesService.create;
    method.call(this.releasesService, this.model).subscribe(
      (release: Release) => {
        if (!this.release.id) {
          this.release.added = true;
        }
        this.release.id = release.id;
        this.release.name = release.name;
        this.release.start = release.start;
        this.release.finish = release.finish;
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
