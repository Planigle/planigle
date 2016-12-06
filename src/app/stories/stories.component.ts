import { Component, OnInit } from '@angular/core';
import { Response } from '@angular/http';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { SelectColumnsComponent } from '../select-columns/select-columns.component';
import { SessionsService } from '../sessions.service';
import { StoryAttributesService } from '../story-attributes.service';
import { ReleasesService } from '../releases.service';
import { IterationsService } from '../iterations.service';
import { TeamsService } from '../teams.service';
import { IndividualsService } from '../individuals.service';
import { StoriesService } from '../stories.service';
import { StoryAttribute } from '../story-attribute';
import { Story } from '../story';
import { Release } from '../release';
import { Iteration } from '../iteration';
import { Team } from '../team';
import { Individual } from '../individual';
import { ApiResponse } from '../api_response';
declare var $: any;

@Component({
  selector: 'app-stories',
  templateUrl: './stories.component.html',
  styleUrls: ['./stories.component.css'],
  providers: [
    SelectColumnsComponent, NgbModal, SessionsService, StoriesService, StoryAttributesService,
    ReleasesService, IterationsService, TeamsService, IndividualsService]
})
export class StoriesComponent implements OnInit {
  public columnDefs: any[] = [];
  public stories: Story[] = [];
  public release: any = 'Current';
  public releases: Release[] = [];
  public iteration: any = 'Current';
  public iterations: Iteration[] = [];
  public team: any = 'MyTeam';
  public teams: Team[] = [];
  public individual: any;
  public individuals: Individual[] = [];
  public status: any = 'NotDone';
  public statuses: any[] = [
    {id: 0, name: 'Not Started'},
    {id: 1, name: 'In Progress'},
    {id: 2, name: 'Blocked'},
    {id: 'NotDone', name: 'Not Done'},
    {id: 3, name: 'Done'},
    {id: 'All', name: 'All Statuses'}
  ];
  private storyAttributes: StoryAttribute[] = [];
  private user: Individual;
  private menusLoaded: boolean = false;

  constructor(
    private modalService: NgbModal,
    private sessionsService: SessionsService,
    private storyAttributesService: StoryAttributesService,
    private releasesService: ReleasesService,
    private iterationsService: IterationsService,
    private teamsService: TeamsService,
    private individualsService: IndividualsService,
    private storiesService: StoriesService
  ) { }

  ngOnInit() {
    this.user = this.sessionsService.getCurrentUser();
    if (this.user) {
      this.addDefaultOptions();
      this.fetchAll();
    } else {
      this.sessionsService.login(null, new ApiResponse(''), false)
        .subscribe(
          (user) => {
            this.user = user;
            this.addDefaultOptions();
            this.fetchAll();
          },
          (err) => this.processError(err));

    }
    this.setGridHeight();
    $(window).resize(this.setGridHeight);
  }

  getChildren(rowItem) {
    if (rowItem.tasks && rowItem.tasks.length > 0) {
      return {
        group: true,
        children: rowItem.tasks
      };
    } else {
      return null;
    }
  }

  selectColumns() {
    const modalRef: NgbModalRef = this.modalService.open(SelectColumnsComponent, {size: 'sm'});
    modalRef.componentInstance.storyAttributes = this.storyAttributes;
    modalRef.result.then((data) => this.setAttributes(this.storyAttributes));
  }

  get enabledIndividuals() {
    return this.individuals.filter((individual: Individual) => {
      return individual.enabled;
    });
  }

  private addDefaultOptions() {
    this.addReleaseOptions(this.releases);
    this.addIterationOptions(this.iterations);
    this.addTeamOptions(this.teams);
    this.addIndividualOptions(this.individuals);
  }

  private setGridHeight() {
    $('ag-grid-ng2').height($(window).height() - 84);
  }

  private setAttributes(storyAttributes: StoryAttribute[]) {
    this.storyAttributes = storyAttributes;
    let newColumnDefs: any[] = [{
      headerName: '',
      width: 20,
      field: 'blank',
      cellRenderer: 'group'
    }];
    storyAttributes.forEach((storyAttribute: StoryAttribute) => {
      if (storyAttribute.show &&
        (this.release === 'All' || storyAttribute.name !== 'Release') &&
        (this.iteration === 'All' || storyAttribute.name !== 'Iteration') &&
        (this.team === 'All' || storyAttribute.name !== 'Team')) {
        let columnDef: any = {
          headerName: storyAttribute.name,
          width: storyAttribute.width,
          storyAttribute: storyAttribute
        };
        if (storyAttribute.getter()) {
          columnDef.valueGetter = storyAttribute.getter();
        } else {
          columnDef.field = storyAttribute.getFieldName();
        }
        if (storyAttribute.getTooltip()) {
          columnDef.tooltipField = storyAttribute.getTooltip();
        }
        newColumnDefs.push(columnDef);
      }
    });
    this.columnDefs = newColumnDefs;
  }

  private fetchStoryAttributes() {
    this.storyAttributesService.getStoryAttributes()
      .subscribe(
        (storyAttributes) => this.setAttributes(storyAttributes),
        (err) => this.processError(err));
  }

  private hasCurrentRelease(releases: Release[]): boolean {
    releases.forEach((release: Release) => {
      if (release.isCurrent()) {
        return true;
      }
    });
    return false;
  }

  private addReleaseOptions(releases: Release[]) {
    let hasCurrentRelease: boolean = this.hasCurrentRelease(releases);
    releases.push(new Release({
      id: '',
      name: 'No Release'
    }));
    releases.push(new Release({
      id: 'All',
      name: 'All Releases'
    }));
    if (hasCurrentRelease) {
      releases.push(new Release({
        id: 'Current',
        name: 'Current Release'
      }));
    }
    this.releases = releases;
    this.release = this.releases[this.releases.length - 1].id;
  }

  private fetchReleases() {
    this.releasesService.getReleases()
      .subscribe(
        (releases: Release[]) => {
          this.addReleaseOptions(releases);
        },
        (err) => this.processError(err));
  }

  private hasCurrentIteration(iterations: Iteration[]): boolean {
    iterations.forEach((iteration: Iteration) => {
      if (iteration.isCurrent()) {
        return true;
      }
    });
    return false;
  }

  private addIterationOptions(iterations: Iteration[]) {
    let hasCurrentIteration: boolean = this.hasCurrentIteration(iterations);
    iterations.push(new Iteration({
      id: '',
      name: 'Backlog'
    }));
    iterations.push(new Iteration({
      id: 'All',
      name: 'All Iterations'
    }));
    if (hasCurrentIteration) {
      iterations.push(new Iteration({
        id: 'Current',
        name: 'Current Iteration'
      }));
    }
    this.iterations = iterations;
    this.iteration = this.iterations[this.iterations.length - 1].id;
  }

  private fetchIterations() {
    this.iterationsService.getIterations()
      .subscribe(
        (iterations: Iteration[]) => {
          this.addIterationOptions(iterations);
        },
        (err) => this.processError(err));
  }

  private addTeamOptions(teams: Team[]) {
    teams.push(new Team({
      id: '',
      name: 'No Team'
    }));
    teams.push(new Team({
      id: 'All',
      name: 'All Teams'
    }));
    teams.push(new Team({
      id: 'MyTeam',
      name: 'My Team'
    }));
    this.teams = teams;
    this.team = this.teams[this.teams.length - 1].id;
  }

  private fetchTeams() {
    this.teamsService.getTeams(this.user.selected_project_id)
      .subscribe(
        (teams: Team[]) => {
          this.addTeamOptions(teams);
        },
        (err) => this.processError(err));

  }

  private addIndividualOptions(individuals: Individual[]) {
    individuals.push(new Individual({
      id: '',
      first_name: 'No',
      last_name: 'Owner',
      enabled: true
    }));
    individuals.push(new Individual({
      id: 'All',
      first_name: 'All',
      last_name: 'Owners',
      enabled: true
    }));
    individuals.push(new Individual({
      id: this.user.id,
      first_name: 'Me',
      enabled: true
    }));
    this.individuals = individuals;
    this.individual = this.individuals[this.individuals.length - 2].id;
  }

  private fetchIndividuals() {
    this.individualsService.getIndividuals()
      .subscribe(
        (individuals: Individual[]) => {
          this.addIndividualOptions(individuals);
        },
        (err) => this.processError(err));
  }

  private fetchStories() {
    this.storiesService.getStories(this.release, this.iteration, this.team, this.individual, this.status)
      .subscribe(
        (stories) => {
          this.stories = stories;
          if (!this.menusLoaded) {
            this.menusLoaded = true;
            this.fetchMenus();
          }
        },
        (err) => this.processError(err));
  }

  private fetchAll() {
    this.fetchStories();
    this.fetchStoryAttributes();
  }

  private fetchMenus() {
    this.fetchReleases();
    this.fetchIterations();
    this.fetchTeams();
    this.fetchIndividuals();
  }

  private getError(error: any): string {
    if (error instanceof Response) {
      const body = error.json() || '';
      return body.error || JSON.stringify(body);
    } else {
      return error.message ? error.message : error.toString();
    }
  }

  private showError(error: string) {
    $('#errorDialog').one('show.bs.modal', function (event) {
      $(this).find('.modal-body').text(error);
    }).modal();
  }

  private processError(error: any) {
    if (error instanceof Response && error.status === 401 || error.status === 422) {
      this.sessionsService.forceLogin();
    } else {
      this.showError(this.getError(error));
    }
  }
}
