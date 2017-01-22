import { NgModule } from '@angular/core';
import { StoriesSummaryComponent } from './components/stories-summary/stories-summary.component';

@NgModule({
  declarations: [
    StoriesSummaryComponent
  ],
  exports: [
    StoriesSummaryComponent
  ]
})
export class PremiumModule { }
