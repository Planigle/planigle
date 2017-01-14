import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { CompaniesService } from '../../services/companies.service';
import { ErrorService } from '../../services/error.service';
import { Registration } from '../../models/registration';

@Component({
  selector: 'app-signup',
  templateUrl: './signup.component.html',
  styleUrls: ['./signup.component.css'],
  providers: [CompaniesService]
})
export class SignupComponent {
  model: Registration = new Registration();
  error: string = '';

  constructor(
    private router: Router,
    private companiesService: CompaniesService,
    private errorService: ErrorService
  ) { }

  ok(): void {
    this.companiesService.register(this.model).subscribe(
      () => window.location.href = 'https://www.planigle.com/products/signup_successful',
      (err: any) => this.error = this.errorService.getError(err)
    );
  }

  cancel(): void {
    this.router.navigate(['login']);
  }
}
