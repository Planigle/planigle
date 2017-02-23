import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { RouterModule, Routes } from '@angular/router';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { Angular2FontawesomeModule } from 'angular2-fontawesome/angular2-fontawesome';
import { AgGridModule } from 'ag-grid-ng2/main';
import { MyDatePicker } from 'mydatepicker/src/my-date-picker/my-date-picker.component';
import { MultiselectDropdownModule } from 'angular-2-dropdown-multiselect/src/multiselect-dropdown';
import { PremiumModule } from '../premium/premium.module';

import { AuthGuardService } from './services/auth-guard.service';
import { ErrorService } from './services/error.service';
import { SessionsService } from './services/sessions.service';
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
import { ChangesComponent } from './components/changes/changes.component';
import { DatesService } from './services/dates.service';
import { HtmlCellComponent } from './components/html-cell/html-cell.component';
import { ReportsComponent } from './components/reports/reports.component';
import { TasksComponent } from './components/tasks/tasks.component';
import { FilterPipe } from './pipes/filter.pipe';
import { TaskOverallActionsComponent } from './components/task-overall-actions/task-overall-actions.component';
import { EpicsComponent } from './components/epics/epics.component';
import { ConfirmAbortComponent } from './components/confirm-abort/confirm-abort.component';
import { GroupHeaderComponent } from './components/group-header/group-header.component';
import { SurveysComponent } from './components/surveys/surveys.component';
import { SurveyExcludedComponent } from './components/survey-excluded/survey-excluded.component';
import { SurveyComponent } from './components/survey/survey.component';
import { EditSuggestionComponent } from './components/edit-suggestion/edit-suggestion.component';

const appRoutes: Routes = [
  { path: '', redirectTo: 'stories', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'signup', component: SignupComponent },
  { path: 'survey', component: SurveyComponent },
  { path: 'reports', component: ReportsComponent, canActivate: [AuthGuardService] },
  { path: 'epics', component: EpicsComponent, canActivate: [AuthGuardService] },
  { path: 'stories', component: StoriesComponent, canActivate: [AuthGuardService] },
  { path: 'tasks', component: TasksComponent, canActivate: [AuthGuardService] },
  { path: 'schedule', component: ScheduleComponent, canActivate: [AuthGuardService] },
  { path: 'people', component: PeopleComponent, canActivate: [AuthGuardService] },
  { path: 'changes', component: ChangesComponent, canActivate: [AuthGuardService] },
  { path: 'surveys', component: SurveysComponent, canActivate: [AuthGuardService] }
];

@NgModule({
  declarations: [
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
    SignupComponent,
    ChangesComponent,
    HtmlCellComponent,
    ReportsComponent,
    TasksComponent,
    FilterPipe,
    TaskOverallActionsComponent,
    EpicsComponent,
    ConfirmAbortComponent,
    GroupHeaderComponent,
    SurveysComponent,
    SurveyExcludedComponent,
    SurveyComponent,
    EditSuggestionComponent
  ],
  entryComponents: [
    SelectColumnsComponent,
    ConfirmationDialogComponent,
    ConfirmAbortComponent,
    EditReasonBlockedComponent,
    EditMultipleComponent,
    EditAttributesComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule,
    NgbModule.forRoot(),
    Angular2FontawesomeModule,
    RouterModule.forRoot(appRoutes),
    MultiselectDropdownModule,
    AgGridModule.withComponents([
      ChooseStatusComponent,
      StoryActionsComponent,
      IterationActionsComponent,
      ReleaseActionsComponent,
      TeamActionsComponent,
      IndividualActionsComponent,
      HtmlCellComponent,
      GroupHeaderComponent,
      SurveyExcludedComponent
    ]),
    PremiumModule
  ],
  providers: [
    ErrorService,
    SessionsService,
    DatesService,
    AuthGuardService,
    NgbActiveModal
  ],
  exports: [
    RouterModule
  ]
})
export class MainModule { }
