import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { MainModule } from './main/main.module';
import { PremiumModule } from './premium/premium.module';
import { AppComponent } from './app.component';

@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    BrowserModule,
    MainModule,
    PremiumModule
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
