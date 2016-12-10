import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterModule, Routes } from '@angular/router';
import { HttpModule } from '@angular/http';
import { AgGridModule } from 'ag-grid-ng2/main';
import { Angular2FontawesomeModule } from 'angular2-fontawesome/angular2-fontawesome';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';

import { AppComponent } from './app.component';
import { LoginComponent } from './login/login.component';
import { StoriesComponent } from './stories/stories.component';
import { HeaderComponent } from './header/header.component';
import { SelectColumnsComponent } from './select-columns/select-columns.component';
import { EditStoryComponent } from './edit-story/edit-story.component';
import { EditTaskComponent } from './edit-task/edit-task.component';
import { ChooseStatusComponent } from './choose-status/choose-status.component';
import { ButtonBarComponent } from './button-bar/button-bar.component';
import { ReasonBlockedComponent } from './reason-blocked/reason-blocked.component';

const appRoutes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: 'stories', component: StoriesComponent },
  { path: '', component: StoriesComponent }
];

@NgModule({
  declarations: [
    AppComponent,
    LoginComponent,
    StoriesComponent,
    HeaderComponent,
    SelectColumnsComponent,
    EditStoryComponent,
    EditTaskComponent,
    ChooseStatusComponent,
    ButtonBarComponent,
    ReasonBlockedComponent
  ],
  entryComponents: [
    SelectColumnsComponent,
    ReasonBlockedComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
    RouterModule.forRoot(appRoutes),
    HttpModule,
    NgbModule.forRoot(),
    Angular2FontawesomeModule,
    AgGridModule.withComponents([
      ChooseStatusComponent,
      ButtonBarComponent
    ])
  ],
  providers: [
    NgbActiveModal
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
