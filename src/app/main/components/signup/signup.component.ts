import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { CompaniesService } from '../../services/companies.service';
import { ErrorService } from '../../services/error.service';
import { Registration } from '../../models/registration';
declare var $: any;

@Component({
  selector: 'app-signup',
  templateUrl: './signup.component.html',
  styleUrls: ['./signup.component.css'],
  providers: [CompaniesService]
})
export class SignupComponent implements OnInit {
  model: Registration = new Registration();
  error: string = '';

  constructor(
    private router: Router,
    private companiesService: CompaniesService,
    private errorService: ErrorService
  ) { }

  ngOnInit(): void {
    setTimeout(() => $('input[autofocus=""]').focus(), 0);
  }

  ok(form): void {
    if (form.valid) {
      this.companiesService.register(this.model).subscribe(
        () => window.location.href = 'https://www.planigle.com/products/signup_successful',
        (err: any) => this.error = this.errorService.getError(err)
      );
    }
  }

  cancel(): void {
    this.router.navigate(['login']);
  }
}
