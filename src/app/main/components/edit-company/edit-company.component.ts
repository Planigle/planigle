import { Component, OnChanges, Input, Output, EventEmitter } from '@angular/core';
import { Router } from '@angular/router';
import { CompaniesService } from '../../services/companies.service';
import { ErrorService } from '../../services/error.service';
import { Company } from '../../models/company';
import { Individual } from '../../models/individual';
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-edit-company',
  templateUrl: './edit-company.component.html',
  styleUrls: ['./edit-company.component.css']
})
export class EditCompanyComponent implements OnChanges {
  @Input() company: Company;
  @Input() me: Individual;
  @Output() closed: EventEmitter<any> = new EventEmitter();

  public model: Company;
  public error: String;

  constructor(
    private router: Router,
    private companiesService: CompaniesService,
    private errorService: ErrorService) {
  }

  ngOnChanges(changes): void {
    if (changes.company) {
      this.model = new Company(this.company);
      setTimeout(() => $('input[autofocus=""]').focus(), 0);
    }
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

  private saveModel(result: FinishedEditing, form: any): void {
    this.companiesService.update(this.model).subscribe(
      (company: Company) => {
        this.company.name = company.name;
        this.company.premium_expiry = company.premium_expiry;
        this.company.premium_limit = company.premium_limit;
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

  viewChanges(): void {
    this.router.navigate(['changes', {type: 'Company', id: this.model.id}]);
  }
}
