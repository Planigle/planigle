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
import { StoryActionsComponent } from './components/story-actions/story-actions.component';
import { EditReasonBlockedComponent } from './components/edit-reason-blocked/edit-reason-blocked.component';
import { ConfirmationDialogComponent } from './components/confirmation-dialog/confirmation-dialog.component';
import { AcceptanceCriteriaComponent } from './components/acceptance-criteria/acceptance-criteria.component';
import { StoryFiltersComponent } from './components/story-filters/story-filters.component';
import { StoryOverallActionsComponent } from './components/story-overall-actions/story-overall-actions.component';
import { CustomAttributesComponent } from './components/custom-attributes/custom-attributes.component';
import { EditMultipleComponent } from './components/edit-multiple/edit-multiple.component';
import { EditAttributesComponent } from './components/edit-attributes/edit-attributes.component';
import { AutoSelectDirective } from './directives/auto-select.directive';
import { IterationsComponent } from './components/iterations/iterations.component';
import { ReleasesComponent } from './components/releases/releases.component';
import { ScheduleComponent } from './components/schedule/schedule.component';
import { EditIterationComponent } from './components/edit-iteration/edit-iteration.component';
import { EditReleaseComponent } from './components/edit-release/edit-release.component';
import { IterationActionsComponent } from './components/iteration-actions/iteration-actions.component';
import { ReleaseActionsComponent } from './components/release-actions/release-actions.component';
import { IterationOverallActionsComponent } from './components/iteration-overall-actions/iteration-overall-actions.component';
import { ReleaseOverallActionsComponent } from './components/release-overall-actions/release-overall-actions.component';
import { PeopleComponent } from './components/people/people.component';
import { TeamsComponent } from './components/teams/teams.component';
import { IndividualsComponent } from './components/individuals/individuals.component';
import { EditCompanyComponent } from './components/edit-company/edit-company.component';
import { EditTeamComponent } from './components/edit-team/edit-team.component';
import { EditIndividualComponent } from './components/edit-individual/edit-individual.component';
import { TeamActionsComponent } from './components/team-actions/team-actions.component';
import { IndividualActionsComponent } from './components/individual-actions/individual-actions.component';
import { IndividualOverallActionsComponent } from './components/individual-overall-actions/individual-overall-actions.component';
import { EditProjectComponent } from './components/edit-project/edit-project.component';
import { SignupComponent } from './components/signup/signup.component';

const appRoutes: Routes = [
  { path: '', redirectTo: 'stories', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'signup', component: SignupComponent },
  { path: 'stories', component: StoriesComponent, canActivate: [AuthGuardService] },
  { path: 'schedule', component: ScheduleComponent, canActivate: [AuthGuardService] },
  { path: 'people', component: PeopleComponent, canActivate: [AuthGuardService] }
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
    StoryActionsComponent,
    EditReasonBlockedComponent,
    ConfirmationDialogComponent,
    AcceptanceCriteriaComponent,
    MyDatePicker,
    StoryFiltersComponent,
    StoryOverallActionsComponent,
    CustomAttributesComponent,
    EditMultipleComponent,
    EditAttributesComponent,
    AutoSelectDirective,
    IterationsComponent,
    ReleasesComponent,
    ScheduleComponent,
    EditIterationComponent,
    EditReleaseComponent,
    IterationActionsComponent,
    ReleaseActionsComponent,
    IterationOverallActionsComponent,
    ReleaseOverallActionsComponent,
    PeopleComponent,
    TeamsComponent,
    IndividualsComponent,
    EditCompanyComponent,
    EditTeamComponent,
    EditIndividualComponent,
    TeamActionsComponent,
    IndividualActionsComponent,
    IndividualOverallActionsComponent,
    EditProjectComponent,
    SignupComponent
  ],
  entryComponents: [
    SelectColumnsComponent,
    ConfirmationDialogComponent,
    EditReasonBlockedComponent,
    EditMultipleComponent,
    EditAttributesComponent
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
      StoryActionsComponent,
      IterationActionsComponent,
      ReleaseActionsComponent,
      TeamActionsComponent,
      IndividualActionsComponent
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
