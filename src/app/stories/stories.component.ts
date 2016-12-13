import { Component, OnInit } from '@angular/core';
import { Response } from '@angular/http';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { GridOptions } from 'ag-grid/main';
import { SelectColumnsComponent } from '../select-columns/select-columns.component';
import { ButtonBarComponent } from '../button-bar/button-bar.component';
import { SessionsService } from '../sessions.service';
import { StoryAttributesService } from '../story-attributes.service';
import { ErrorService } from '../error.service';
import { ProjectsService } from '../projects.service';
import { ReleasesService } from '../releases.service';
import { IterationsService } from '../iterations.service';
import { TeamsService } from '../teams.service';
import { IndividualsService } from '../individuals.service';
import { StoriesService } from '../stories.service';
import { TasksService } from '../tasks.service';
import { StoryAttribute } from '../story-attribute';
import { Story } from '../story';
import { Task } from '../task';
import { Project } from '../project';
import { Release } from '../release';
import { Iteration } from '../iteration';
import { Team } from '../team';
import { Individual } from '../individual';
declare var $: any;

@Component({
  selector: 'app-stories',
  templateUrl: './stories.component.html',
  styleUrls: ['./stories.component.css'],
  providers: [
    SelectColumnsComponent, NgbModal, StoriesService, TasksService, StoryAttributesService,
    ProjectsService, ReleasesService, IterationsService, TeamsService, IndividualsService]
})
export class StoriesComponent implements OnInit {
  public gridOptions: GridOptions = <GridOptions>{};
  public columnDefs: any[] = [];
  public stories: Story[] = [];
  public projects: Project[] = [];
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
  public selection: any = null;
  private storyAttributes: StoryAttribute[] = [];
  private user: Individual;
  private menusLoaded: boolean = false;

  constructor(
    private modalService: NgbModal,
    private sessionsService: SessionsService,
    private storyAttributesService: StoryAttributesService,
    private projectsService: ProjectsService,
    private releasesService: ReleasesService,
    private iterationsService: IterationsService,
    private teamsService: TeamsService,
    private individualsService: IndividualsService,
    private storiesService: StoriesService,
    private tasksService: TasksService,
    private errorService: ErrorService
  ) { }

  ngOnInit() {
    this.user = new Individual(this.sessionsService.getCurrentUser());
    this.addDefaultOptions();
    this.fetchAll();
    this.setGridHeight();
    $(window).resize(this.setGridHeight);
  }

  getChildren(rowItem) {
    if (rowItem.tasks && rowItem.tasks.length > 0) {
      return {
        group: true,
        children: rowItem.tasks,
        expanded: rowItem.expanded
      };
    } else {
      return null;
    }
  }

  rowGroupOpened(event) {
    event.node.data.expanded = event.node.expanded;
  }

  selectColumns() {
    const modalRef: NgbModalRef = this.modalService.open(SelectColumnsComponent, {size: 'sm'});
    modalRef.componentInstance.storyAttributes = this.storyAttributes;
    modalRef.result.then((data) => this.setAttributes(this.storyAttributes));
  }

  selectRow(event) {
    this.selection = event.data;
  }

  clearSelection() {
    if (this.selection) {
      this.checkRemoveRow(this.selection);
    }
    this.selection = null;
    this.gridOptions.api.refreshView();
  }

  private checkRemoveRow(row) {
    let filtered = false;
    if (row.isStory()) {
      if (this.release !== 'All') {
        if (this.release === '') {
          filtered = filtered || row.release_id;
        } else if (this.release === 'Current') {
          filtered = filtered || (row.release_id !== this.getCurrentRelease(this.releases));
        } else {
          filtered = filtered || (row.release_id !== this.release);
        }
      }
      if (this.iteration !== 'All') {
        if (this.iteration === '') {
          filtered = filtered || row.iteration_id;
        } else if (this.iteration === 'Current') {
          filtered = filtered || (row.iteration_id !== this.getCurrentIteration(this.iterations));
        } else {
          filtered = filtered || (row.iteration_id !== this.iteration);
        }
      }
      if (this.team !== 'All') {
        if (this.team === '') {
          filtered = filtered || row.team_id;
        } else if (this.team === 'MyTeam') {
          filtered = filtered || (row.team_id !== this.user.team_id);
        } else {
          filtered = filtered || (row.team_id !== this.team);
        }
      }
      if (this.individual !== 'All') {
        if (this.individual === '') {
          filtered = filtered || row.individual_id;
        } else {
          filtered = filtered || (row.individual_id !== this.individual);
        }
      }
    }
    if (this.status !== 'All') {
      if (this.status === 'NotDone') {
        filtered = filtered || (row.status_code === 3);
      } else {
        filtered = filtered || (row.status_code !== this.status);
      }
    }
    if (filtered) {
      if (row.isStory()) {
        this.stories.splice(this.getIndex(this.stories, row.id), 1);
      } else {
        this.stories.forEach((story) => {
          if (story.id === row.story_id) {
            story.tasks.splice(this.getIndex(story.tasks, row.id), 1);
          }
        });
      }
      this.stories = this.stories.slice(0); // Force ag-grid to deal with change in rows
    }
    this.storiesService.setRanks(this.stories);
  }

  private getIndex(objects, id) {
    let index = -1;
    let i = 0;
    objects.forEach((object) => {
      if (object.id === id) {
        index = i;
      }
      i++;
    });
    return index;
  }

  get enabledIndividuals() {
    return this.individuals.filter((individual: Individual) => {
      return individual.enabled;
    });
  }

  get choosableReleases() {
    return this.releases.filter((release: Release) => {
      return release.name !== 'All Releases' && release.name !== 'Current Release' && release.name !== 'No Release';
    });
  }

  get choosableIterations() {
    return this.iterations.filter((iteration: Iteration) => {
      return iteration.name !== 'All Iterations' && iteration.name !== 'Current Iteration' && iteration.name !== 'Backlog';
    });
  }

  get choosableTeams() {
    return this.teams.filter((team: Team) => {
      return team.name !== 'All Teams' && team.name !== 'My Team' && team.name !== 'No Team';
    });
  }

  get choosableIndividuals() {
    return this.individuals.filter((individual: Individual) => {
      return individual.enabled && individual.name !== 'All Owners' && individual.name !== 'Me' && individual.name !== 'No Owner';
    });
  }

  get context(): any {
    return {
      me: this.user,
      gridHolder: this,
      updateFunction: this.statusChanged
    };
  }

  private statusChanged(gridHolder, row) {
    if (row.isStory()) {
      gridHolder.storiesService.update(row).subscribe(
        (story: Story) => gridHolder.updateGridForStatusChange(gridHolder, story),
        (err) => gridHolder.processError(gridHolder, err));
    } else {
      gridHolder.tasksService.update(row).subscribe(
        (task: Task) => {
          gridHolder.updateGridForStatusChange(gridHolder, task);
          let statusChanged = false;
          if (row.status_code === 2 && row.story.status_code !== 2) {
            row.story.status_code = 2;
            statusChanged = true;
          } else if (row.status_code > 0 && row.story.status_code === 0) {
            row.story.status_code = 1;
            statusChanged = true;
          }
          if (statusChanged) {
            gridHolder.storiesService.update(row.story).subscribe(
              (story: Story) => gridHolder.updateGridForStatusChange(gridHolder, row.story),
              (err) => gridHolder.processError(gridHolder, err));
          }
        },
        (err) => gridHolder.processError(err));
    }
  }

  updateGridForStatusChange(gridHolder, row) {
    gridHolder.checkRemoveRow(row);
    gridHolder.gridOptions.api.refreshView();
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
      cellRenderer: 'group',
      suppressMovable: true,
      suppressResize: true,
      suppressSorting: true
    }, {
      headerName: '',
      width: 18,
      field: 'blank',
      cellRendererFramework: ButtonBarComponent,
      suppressMovable: true,
      suppressResize: true,
      suppressSorting: true
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
        if (storyAttribute.getCellRenderer()) {
          columnDef.cellRendererFramework = storyAttribute.getCellRenderer();
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

  private fetchProjects() {
    this.projectsService.getProjects()
      .subscribe(
        (projects) => this.projects = projects,
        (err) => this.processError(err));
  }

  private hasCurrentRelease(releases: Release[]): boolean {
    return this.getCurrentRelease(releases) !== null;
  }

  private getCurrentRelease(releases: Release[]): Release {
    releases.forEach((release: Release) => {
      if (release.isCurrent()) {
        return release;
      }
    });
    return null;
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
    return this.getCurrentIteration(iterations) !== null;
  }

  private getCurrentIteration(iterations: Iteration[]): Iteration {
    iterations.forEach((iteration: Iteration) => {
      if (iteration.isCurrent()) {
        return iteration;
      }
    });
    return null;
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
    this.fetchProjects();
  }

  public showError(error: string) {
    $('#errorDialog').one('show.bs.modal', function (event) {
      $(this).find('.modal-body').text(error);
    }).modal();
  }

  private processError(error: any) {
    this.processRemoteError(this, error);
  }

  private processRemoteError(gridHolder, error: any) {
    if (error instanceof Response && error.status === 401 || error.status === 422) {
      gridHolder.sessionsService.forceLogin();
    } else {
      gridHolder.showError(gridHolder.errorService.getError(error));
    }
  }
}
