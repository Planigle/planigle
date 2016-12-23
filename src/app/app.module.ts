import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterModule, Routes } from '@angular/router';
import { HttpModule } from '@angular/http';
import { AgGridModule } from 'ag-grid-ng2/main';
import { Angular2FontawesomeModule } from 'angular2-fontawesome/angular2-fontawesome';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { MyDatePicker } from 'mydatepicker/src/my-date-picker/my-date-picker.component';

import { AuthGuardService } from './services/auth-guard.service';
import { ErrorService } from './services/error.service';
import { SessionsService } from './services/sessions.service';
import { AppComponent } from './app.component';
import { LoginComponent } from './components/login/login.component';
import { StoriesComponent } from './components/stories/stories.component';
import { HeaderComponent } from './components/header/header.component';
import { SelectColumnsComponent } from './components/select-columns/select-columns.component';
import { EditStoryComponent } from './components/edit-story/edit-story.component';
import { EditTaskComponent } from './components/edit-task/edit-task.component';
import { ChooseStatusComponent } from './components/choose-status/choose-status.component';
import { ButtonBarComponent } from './components/button-bar/button-bar.component';
import { ReasonBlockedComponent } from './components/reason-blocked/reason-blocked.component';
import { ConfirmationDialogComponent } from './components/confirmation-dialog/confirmation-dialog.component';
import { AcceptanceCriteriaComponent } from './components/acceptance-criteria/acceptance-criteria.component';

const appRoutes: Routes = [
  { path: '', redirectTo: 'stories', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'stories', component: StoriesComponent, canActivate: [AuthGuardService] }
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
    ReasonBlockedComponent,
    ConfirmationDialogComponent,
    AcceptanceCriteriaComponent,
    MyDatePicker
  ],
  entryComponents: [
    SelectColumnsComponent,
    ConfirmationDialogComponent,
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
    NgbActiveModal,
    ErrorService,
    SessionsService,
    AuthGuardService
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
