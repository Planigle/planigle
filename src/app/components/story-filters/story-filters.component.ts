import { Component, Input, OnChanges, NgZone, ViewChild, ElementRef } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { StoriesComponent } from '../../components/stories/stories.component';
import { ReleasesService } from '../../services/releases.service';
import { IterationsService } from '../../services/iterations.service';
import { TeamsService } from '../../services/teams.service';
import { IndividualsService } from '../../services/individuals.service';
import { Release } from '../../models/release';
import { Iteration } from '../../models/iteration';
import { Team } from '../../models/team';
import { Individual } from '../../models/individual';
import { StoryAttribute } from '../../models/story-attribute';

@Component({
  selector: 'app-story-filters',
  templateUrl: './story-filters.component.html',
  styleUrls: ['./story-filters.component.css'],
  providers: [ ReleasesService, IterationsService, TeamsService, IndividualsService ]
})
export class StoryFiltersComponent implements OnChanges {
  private static defaultRelease = 'Current';
  private static defaultIteration = 'Current';
  private static defaultTeam = 'MyTeam';
  private static defaultIndividual = 'All';
  private static defaultStatus = 'NotDone';
  private static all: string = '-1';
  @Input() grid: StoriesComponent;
  @Input() customStoryAttributes: StoryAttribute[];
  @ViewChild('searchTextInput') searchTextInput: ElementRef;
  public release: any;
  public releases: Release[] = [];
  public iteration: any;
  public iterations: Iteration[] = [];
  public team: any;
  public teams: Team[] = [];
  public individual: any;
  public individuals: Individual[] = [];
  public status: any;
  public showMoreOptions: boolean = false;
  public customValues: Map<string,any> = new Map();
  private searchText: string = '';
  private hasAdditionalFilters: boolean =  false;
  
  statuses: any[] = [
    {id: 0, name: 'Not Started'},
    {id: 1, name: 'In Progress'},
    {id: 2, name: 'Blocked'},
    {id: 'NotDone', name: 'Not Done'},
    {id: 3, name: 'Done'},
    {id: 'All', name: 'All Statuses'}
  ];
  
  constructor(
    private ngzone: NgZone,
    private releasesService: ReleasesService,
    private iterationsService: IterationsService,
    private teamsService: TeamsService,
    private individualsService: IndividualsService
  ) { }
  
  ngOnChanges(changes: any): void {
    if (changes.customStoryAttributes) {
      this.customStoryAttributes.forEach((storyAttribute) => {
        if (!this.customValues[storyAttribute.id]) {
          this.customValues[storyAttribute.id] = StoryFiltersComponent.all;
        }
      });
    }
  }
  
  ngAfterViewInit(): void {
    this.ngzone.runOutsideAngular(() => {
      Observable.fromEvent(this.searchTextInput.nativeElement, 'keyup')
        .debounceTime(1000)
        .subscribe(keyboardEvent => {
          this.updateNavigation();
        });
    });
  }
  
  get enabledIndividuals(): Individual[] {
    return this.individuals.filter((individual: Individual) => {
      return individual.enabled;
    });
  }
  
  get queryString(): string {
    let queryString = '?';
    if (this.release !== 'All') {
      queryString += 'release_id=' + (this.release ? this.release : '') + '&';
    }
    if (this.iteration !== 'All') {
      queryString += 'iteration_id=' + (this.iteration ? this.iteration : '') + '&';
    }
    if (this.team !== 'All') {
      queryString += 'team_id=' + (this.team ? this.team : '') + '&';
    }
    if (this.individual !== 'All') {
      queryString += 'individual_id=' + (this.individual ? this.individual : '') + '&';
    }
    if (this.status !== 'All') {
      queryString += 'status_code=' + this.status + '&';
    }
    if (this.searchText !== '') {
      queryString += 'text=' + this.searchText + '&';
    }
    for(let key in this.customValues) {
      let value = this.customValues[key];
      if(value != StoryFiltersComponent.all) {
        queryString += 'custom_' + key + '=' + (value === 'null' ? '' : value) + '&';
      }
    };
    return queryString.substring(0, queryString.length - 1);
  }
  
  updateNavigation(): void {
    this.grid.updateNavigation();
  }
  
  applyNavigation(params: Map<string,string>): void {
    this.hasAdditionalFilters = false;
    this.release = params['release'] == null ? StoryFiltersComponent.defaultRelease : params['release'];
    this.iteration = params['iteration'] == null ? StoryFiltersComponent.defaultIteration : params['iteration'];
    this.team = params['team'] == null ? StoryFiltersComponent.defaultTeam : params['team'];
    this.individual = params['individual'] == null ? StoryFiltersComponent.defaultIndividual : params['individual'];
    this.status = params['status'] == null ? StoryFiltersComponent.defaultStatus : params['status'];
    this.searchText = params['text'] == null ? '' : params['text'];
    if(this.searchText !== '') {
      this.hasAdditionalFilters = true;
    }
    if(this.customValues.size == 0) { // not set yet
      for(let key in params) {
        if(key.length > 7 && key.substring(0,7) === 'custom_') {
          let value = params[key];
          this.customValues[key.substring(7)] = value == null ? StoryFiltersComponent.all : (value === '' ? 'null' : value);
          if(value != null) {
            this.hasAdditionalFilters = true
          }
        }
      };
    } else {
      for(let key in this.customValues) {
        let value = params['custom_' + key];
        this.customValues[key] = value == null ? StoryFiltersComponent.all : (value === '' ? 'null' : value);
        if(value != null) {
          this.hasAdditionalFilters = true
        }
      };
    }
  }
  
  updateNavigationParams(params: Map<string,string>): void {
    if (this.release !== StoryFiltersComponent.defaultRelease) {
      params['release'] = this.release;
    }
    if (this.iteration !== StoryFiltersComponent.defaultIteration) {
      params['iteration'] = this.iteration;
    }
    if (this.team !== StoryFiltersComponent.defaultTeam) {
      params['team'] = this.team;
    }
    if (this.individual !== StoryFiltersComponent.defaultIndividual) {
      params['individual'] = this.individual;
    }
    if (this.status !== StoryFiltersComponent.defaultStatus) {
      params['status'] = this.status;
    }
    if (this.searchText !== '') {
      params['text'] = this.searchText;
    }
    for(let key in this.customValues) {
      let value = this.customValues[key];
      if(value != StoryFiltersComponent.all) {
        params['custom_' + key] = (value === 'null' ? '' : value);
      }
    }
  }

  addDefaultOptions(user: Individual): void {
    this.addReleaseOptions(this.releases);
    this.addIterationOptions(this.iterations);
    this.addTeamOptions(this.teams);
    this.addIndividualOptions(this.individuals, user);
  }

  addReleaseOptions(releases: Release[]): void {
    releases.push(new Release({
      id: '',
      name: 'No Release'
    }));
    releases.push(new Release({
      id: 'All',
      name: 'All Releases'
    }));
    releases.push(new Release({
      id: 'Current',
      name: 'Current Release'
    }));
    this.releases = releases;
    if (this.release != null) {
      let index = this.grid.getIndex(this.releases, this.release);
      this.release = index !== -1 ? this.releases[index].id : null;
    }
    if (this.release == null) {
      this.release = this.releases[this.releases.length - 1].id;
    }
  }

  addIterationOptions(iterations: Iteration[]): void {
    iterations.push(new Iteration({
      id: '',
      name: 'Backlog'
    }));
    iterations.push(new Iteration({
      id: 'All',
      name: 'All Iterations'
    }));
    iterations.push(new Iteration({
      id: 'Current',
      name: 'Current Iteration'
    }));
    this.iterations = iterations;
    if (this.iteration != null) {
      let index = this.grid.getIndex(this.iterations, this.iteration);
      this.iteration = index !== -1 ? this.iterations[index].id : null;
    }
    if (this.iteration == null) {
      this.iteration = this.iterations[this.iterations.length - 1].id;
    }
  }

  addTeamOptions(teams: Team[]): void {
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
    if (this.team != null) {
      let index = this.grid.getIndex(this.teams, this.team);
      this.team = index !== -1 ? this.teams[index].id : null;
    }
    if (this.team == null) {
      this.team = this.teams[this.teams.length - 1].id;
    }
  }

  addIndividualOptions(individuals: Individual[], user: Individual): void {
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
      id: user.id,
      first_name: 'Me',
      enabled: true
    }));
    this.individuals = individuals;
    if (this.individual != null) {
      let index = this.grid.getIndex(this.individuals, this.individual);
      this.individual = index !== -1 ? this.individuals[index].id : null;
    }
    if (this.individual == null) {
      this.individual = this.individuals[this.individuals.length - 2].id;
    }
  }

  getCurrentReleaseId(releases: Release[]): number {
    let result: number = null;
    releases.forEach((release: Release) => {
      if (release.start && release.finish && release.isCurrent()) {
        result = release.id;
      }
    });
    return result;
  }

  getCurrentIterationId(iterations: Iteration[]): number {
    let result: number = null;
    iterations.forEach((iteration: Iteration) => {
      if (iteration.start && iteration.finish && iteration.isCurrent()) {
        result = iteration.id;
      }
    });
    return result;
  }
  
  get choosableReleases(): Release[] {
    return this.releases.filter((release: Release) => {
      return release.name !== 'All Releases' && release.name !== 'Current Release' && release.name !== 'No Release';
    });
  }

  get choosableIterations(): Iteration[] {
    return this.iterations.filter((iteration: Iteration) => {
      return iteration.name !== 'All Iterations' && iteration.name !== 'Current Iteration' && iteration.name !== 'Backlog';
    });
  }

  get choosableTeams(): Team[] {
    return this.teams.filter((team: Team) => {
      return team.name !== 'All Teams' && team.name !== 'My Team' && team.name !== 'No Team';
    });
  }

  get choosableIndividuals(): Individual[] {
    return this.individuals.filter((individual: Individual) => {
      return individual.enabled && individual.name !== 'All Owners' && individual.name !== 'Me' && individual.name !== 'No Owner';
    });
  }
  
  toggleMoreOptions(): void {
    this.showMoreOptions = !this.showMoreOptions;
  }

  fetchMenus(user: Individual) {
    this.fetchReleases();
    this.fetchIterations();
    this.fetchTeams(user);
    this.fetchIndividuals(user);
  }

  private fetchReleases(): void {
    this.releasesService.getReleases()
      .subscribe(
        (releases: Release[]) => {
          this.addReleaseOptions(releases);
        });
  }

  private fetchIterations(): void {
    this.iterationsService.getIterations()
      .subscribe(
        (iterations: Iteration[]) => {
          this.addIterationOptions(iterations);
        });
  }

  private fetchTeams(user: Individual): void {
    this.teamsService.getTeams(user.selected_project_id)
      .subscribe(
        (teams: Team[]) => {
          this.addTeamOptions(teams);
        });

  }

  private fetchIndividuals(user: Individual): void {
    this.individualsService.getIndividuals()
      .subscribe(
        (individuals: Individual[]) => {
          this.addIndividualOptions(individuals, user);
        });
  }
}
