import { Component, Input } from '@angular/core';
import { StoriesComponent } from '../../components/stories/stories.component';
import { ReleasesService } from '../../services/releases.service';
import { IterationsService } from '../../services/iterations.service';
import { TeamsService } from '../../services/teams.service';
import { IndividualsService } from '../../services/individuals.service';
import { Release } from '../../models/release';
import { Iteration } from '../../models/iteration';
import { Team } from '../../models/team';
import { Individual } from '../../models/individual';

@Component({
  selector: 'app-story-filters',
  templateUrl: './story-filters.component.html',
  styleUrls: ['./story-filters.component.css'],
  providers: [ ReleasesService, IterationsService, TeamsService, IndividualsService ]
})
export class StoryFiltersComponent {
  @Input() grid: StoriesComponent;
  public release: any;
  public releases: Release[] = [];
  public iteration: any;
  public iterations: Iteration[] = [];
  public team: any;
  public teams: Team[] = [];
  public individual: any;
  public individuals: Individual[] = [];
  public status: any;
  statuses: any[] = [
    {id: 0, name: 'Not Started'},
    {id: 1, name: 'In Progress'},
    {id: 2, name: 'Blocked'},
    {id: 'NotDone', name: 'Not Done'},
    {id: 3, name: 'Done'},
    {id: 'All', name: 'All Statuses'}
  ];
  
  constructor(
    private releasesService: ReleasesService,
    private iterationsService: IterationsService,
    private teamsService: TeamsService,
    private individualsService: IndividualsService
  ) { }
  
  get enabledIndividuals(): Individual[] {
    return this.individuals.filter((individual: Individual) => {
      return individual.enabled;
    });
  }

  updateNavigation(): void {
    this.grid.updateNavigation();
  }

  addDefaultOptions(user: Individual): void {
    this.addReleaseOptions(this.releases);
    this.addIterationOptions(this.iterations);
    this.addTeamOptions(this.teams);
    this.addIndividualOptions(this.individuals, user);
  }

  addReleaseOptions(releases: Release[]): void {
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
    if (this.release != null) {
      let index = this.grid.getIndex(this.releases, this.release);
      this.release = index !== -1 ? this.releases[index].id : null;
    }
    if (this.release == null) {
      this.release = this.releases[this.releases.length - 1].id;
    }
  }

  addIterationOptions(iterations: Iteration[]): void {
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
    releases.forEach((release: Release) => {
      if (release.start && release.finish && release.isCurrent()) {
        return release.id;
      }
    });
    return null;
  }

  getCurrentIterationId(iterations: Iteration[]): number {
    iterations.forEach((iteration: Iteration) => {
      if (iteration.start && iteration.finish && iteration.isCurrent()) {
        return iteration.id;
      }
    });
    return null;
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
  
  private hasCurrentRelease(releases: Release[]): boolean {
    return this.getCurrentReleaseId(releases) !== null;
  }

  private hasCurrentIteration(iterations: Iteration[]): boolean {
    return this.getCurrentIterationId(iterations) !== null;
  }
}
