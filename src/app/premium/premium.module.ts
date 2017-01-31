import { NgModule } from '@angular/core';
import { StoriesSummaryComponent } from './components/stories-summary/stories-summary.component';
import { PremiumReportsComponent } from './components/premium-reports/premium-reports.component';

@NgModule({
  declarations: [
    StoriesSummaryComponent,
    PremiumReportsComponent
  ],
  exports: [
    StoriesSummaryComponent,
    PremiumReportsComponent
  ]
})
export class PremiumModule { }
