import { Component, OnInit } from '@angular/core';
import { Response } from '@angular/http';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { GridOptions } from 'ag-grid/main';
import { SelectColumnsComponent } from '../select-columns/select-columns.component';
import { ButtonBarComponent } from '../button-bar/button-bar.component';
import { SessionsService } from '../../services/sessions.service';
import { StoryAttributesService } from '../../services/story-attributes.service';
import { ErrorService } from '../../services/error.service';
import { ProjectsService } from '../../services/projects.service';
import { ReleasesService } from '../../services/releases.service';
import { IterationsService } from '../../services/iterations.service';
import { TeamsService } from '../../services/teams.service';
import { IndividualsService } from '../../services/individuals.service';
import { StoriesService } from '../../services/stories.service';
import { TasksService } from '../../services/tasks.service';
import { StoryAttribute } from '../../models/story-attribute';
import { Story } from '../../models/story';
import { Task } from '../../models/task';
import { Project } from '../../models/project';
import { Release } from '../../models/release';
import { Iteration } from '../../models/iteration';
import { Team } from '../../models/team';
import { Individual } from '../../models/individual';
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
  static instance: StoriesComponent;
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
  public user: Individual;
  public waiting: boolean = false;
  private storyAttributes: StoryAttribute[] = [];
  private filteredAttributes: StoryAttribute[] = [];
  private menusLoaded: boolean = false;
  private id_map: any = {};

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
  ) {
    StoriesComponent.instance = this;
  }

  ngOnInit(): void {
    this.user = new Individual(this.sessionsService.getCurrentUser());
    this.addDefaultOptions();
    this.fetchAll();
    this.setGridHeight();
    $(window).resize(this.setGridHeight);
    $('#import').fileupload(this.getFileUploadOptions());
  }

  private getFileUploadOptions(): any {
    let self = this;
    return {
      add: function(e, data) {
        self.waiting = true;
        data.submit();
      },
      done: function(e, data) {
        self.fetchStories();
        self.waiting = false;
      },
      fail: function (e, data) {
        self.waiting = false;
        self.errorService.showError(data.jqXHR.responseJSON.error);
      }
    };
  }

  gridReady(): void {
    let self: StoriesComponent = this;
    let interval: any = null;
    const scrollAmount = 150;
    $('.ag-row').draggable({
      appendTo: '.ag-body-viewport',
      zIndex: 100,
      axis: 'y',
      helper: 'clone',
      revert: 'invalid',
      start: function(event: any, ui: any) {
        $('.scroll-up, .scroll-down').css('z-index', 10);
      },
      stop: function(event: any, ui: any) {
        $('.scroll-up, .scroll-down').css('z-index', -10);
      }
    }).droppable({
      drop: self.dropRow,
      tolerance: 'pointer'
    });
    $('.scroll-up').droppable({
      over: function(event: any, ui: any){
        interval = setInterval(function() {
          let scroll: number = $('.ag-body-viewport').scrollTop();
          let diff: number = scroll < scrollAmount ? -scroll : -scrollAmount;
          if (diff < 0) {
            $('.ag-body-viewport').scrollTop(scroll + diff);
          }
        }, 200);
      },
      out: function(event: any, ui: any){
        if (interval !== null) {
          clearInterval(interval);
          interval = null;
        }
      }
    });

    $('.scroll-down').droppable({
      drop: self.dropRow,
      over: function(event: any, ui: any){
        interval = setInterval(function() {
          let scroll: number = $('.ag-body-viewport').scrollTop();
          let maxScroll: number = $('.ag-body-viewport').prop('scrollHeight') - $('.ag-body-viewport').innerHeight();
          let diff: number = scroll + scrollAmount > maxScroll ? (maxScroll - scrollAmount) : scrollAmount;
          if (diff > 0) {
            $('.ag-body-viewport').scrollTop(scroll + diff);
          }
        }, 200);
      },
      out: function(event: any, ui: any){
        if (interval !== null) {
          clearInterval(interval);
          interval = null;
        }
      }
    });
  }

  getChildren(rowItem: any): any {
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

  rowGroupOpened(event: any): void {
    event.node.data.expanded = event.node.expanded;
  }

  selectColumns(): void {
    const modalRef: NgbModalRef = this.modalService.open(SelectColumnsComponent, {size: 'sm'});
    modalRef.componentInstance.storyAttributes = this.storyAttributes;
    modalRef.result.then((data) => this.setAttributes(this.storyAttributes));
  }

  addStory(): void {
    let release_id: number = null;
    if (this.release !== 'All' && this.release !== '') {
      release_id = this.release === 'Current' ? this.getCurrentRelease(this.releases).id : parseInt(this.release, 10);
    }
    let iteration_id: number = null;
    if (this.iteration !== 'All' && this.iteration !== '') {
      iteration_id = this.iteration === 'Current' ? this.getCurrentIteration(this.iterations).id : parseInt(this.iteration, 10);
    }
    let team_id: number = null;
    if (this.team !== 'All' && this.team !== '') {
      team_id = this.team === 'MyTeam' ? this.user.team_id : parseInt(this.team, 10);
    }
    let story: Story = new Story({
      status_code: 0,
      release_id: release_id,
      iteration_id: iteration_id,
      team_id: team_id,
      individual_id: null
    });
    this.selection = story;
  }

  selectRow(event): void {
    this.selection = event.data;
  }

  clearSelection(): void {
    if (this.selection) {
      if (this.selection.added) {
        this.selection.added = false;
        this.addRow(this.selection);
        this.gridOptions.api.setRowData(this.stories);
      } else {
        this.checkRemoveRow(this.selection);
        this.gridOptions.api.refreshView();
      }
    }
    this.selection = null;
  }

  moveColumn(event): void {
    let storyAttribute: StoryAttribute = event.column.colDef.storyAttribute;
    if (storyAttribute) {
      let oldIndex: number = this.getIndex(this.filteredAttributes, storyAttribute.id);
      let newIndex: number = event.toIndex - 2; // ignore first columns;
      newIndex = newIndex < 0 ? 0 : newIndex;
      if (oldIndex !== newIndex) {
        let min: number = newIndex < oldIndex ?
          (newIndex === 0 ?
            this.filteredAttributes[0].ordering - 20 :
            this.filteredAttributes[newIndex - 1].ordering) :
          this.filteredAttributes[newIndex].ordering;
        let max: number = newIndex > oldIndex ?
          (newIndex === this.filteredAttributes.length - 1 ?
            this.filteredAttributes[newIndex].ordering + 20 :
            this.filteredAttributes[newIndex + 1].ordering) :
          this.filteredAttributes[newIndex].ordering;
        storyAttribute.ordering = min + ((max - min) / 2);
        this.storyAttributesService.update(storyAttribute)
          .subscribe((result) => {});
      }
    }
  }

  resizeColumn(event: any): void {
    let storyAttribute: StoryAttribute = event.column.colDef.storyAttribute;
    if (storyAttribute) {
      storyAttribute.width = event.column.actualWidth;
      this.storyAttributesService.update(storyAttribute)
        .subscribe((result: StoryAttribute) => {});
    }
  }

  public getRowClass(rowItem: any): string {
    return (rowItem.data.isStory() ? 'story' : 'task') + ' id-' + rowItem.data.uniqueId;
  }

  public getRowNodeId(rowItem): string {
    return rowItem.uniqueId;
  }

  public dropRow(event, ui): void {
    let self: StoriesComponent = StoriesComponent.instance;
    function getRow(jQueryObject: any) {
      let result: string = null;
      $.each($(jQueryObject).attr('class').toString().split(' '), function (i: number, className: string) {
        if (className.indexOf('id-') === 0) {
          result = className.substring(3);
        }
      });
      return self.id_map[result];
    }

    let movedRow: any = getRow(ui.draggable[0]);
    let targetRow: any = getRow(this);
    if (movedRow.isStory()) {
      // Move story
      if (targetRow && !targetRow.isStory()) {
        // If moving story to task, move after story for task
        let index = self.stories.indexOf(targetRow.story) + 1;
        if (index >= self.stories.length) {
          targetRow = null;
        } else {
          targetRow = self.stories[index];
        }
      }
      self.stories.splice(self.stories.indexOf(movedRow), 1);
      if (targetRow) {
        self.stories.splice(self.stories.indexOf(targetRow), 0, movedRow);
      } else {
        self.stories.push(movedRow);
      }
      movedRow.priority = self.determinePriority(self.stories, movedRow);
      self.storiesService.update(movedRow).subscribe((story) => {}, (error) => self.processError.call(self, error));
    } else {
      // Move task
      let oldStory: Story = movedRow.story;
      oldStory.tasks.splice(oldStory.tasks.indexOf(movedRow), 1);
      let index: number = targetRow ? self.stories.indexOf(targetRow) : -1;
      let newStory: Story = targetRow ?
        (targetRow.isStory() ? (self.stories[index === 0 ? 0 : index - 1]) : targetRow.story) :
        self.stories[self.stories.length - 1];
      if (oldStory.id !== newStory.id) {
        movedRow.story = newStory;
        movedRow.previous_story_id = oldStory.id;
        movedRow.story_id = newStory.id;
      }
      if (targetRow && !targetRow.isStory()) {
        // Moving to within tasks
        newStory.tasks.splice(newStory.tasks.indexOf(targetRow), 0, movedRow);
      } else {
        // Moving to end of tasks
        newStory.tasks.push(movedRow);
      }
      movedRow.priority = self.determinePriority(newStory.tasks, movedRow);
      self.tasksService.update(movedRow)
        .subscribe((task) => movedRow.previous_story_id = null, (error) => self.processError.call(self, error));
      newStory.expanded = true;
    }
    self.gridOptions.api.setRowData(self.stories);
  }

  private determinePriority(objects, object): number {
    //  Return a number between the priorities of the surrounding elements
    if (objects.length === 1) {
      return 10;
    } else {
      let index: number = objects.indexOf(object);
      let min: number = index === 0 ? objects[index + 1].priority - 20 : objects[index - 1].priority;
      let max: number = index === objects.length - 1 ? objects[objects.length - 2].priority + 20 : objects[index + 1].priority;
      return min + ((max - min) / 2);
    }
  }

  private addRow(row): void {
    this.id_map[row.uniqueId] = row;
    if (row.isStory()) {
      this.stories.push(row);
      this.storiesService.setRanks(this.stories);
    } else {
      this.stories.forEach((story: any) => {
        if (story.id === row.story_id) {
          story.expanded = true;
          story.tasks.push(row);
        }
      });
    }
  }

  private checkRemoveRow(row: any) {
    let filtered = false;
    if ( row.deleted ) {
      filtered = true;
    } else if (row.isStory()) {
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

  private getIndex(objects: any[], id: number): number {
    let index: number = -1;
    let i = 0;
    objects.forEach((object: any) => {
      if (object.id === id) {
        index = i;
      }
      i++;
    });
    return index;
  }

  get enabledIndividuals(): Individual[] {
    return this.individuals.filter((individual: Individual) => {
      return individual.enabled;
    });
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

  get context(): any {
    return {
      me: this.user,
      gridHolder: this,
      updateFunction: this.statusChanged
    };
  }

  private statusChanged(gridHolder: StoriesComponent, row: any): void {
    if (row.isStory()) {
      gridHolder.storiesService.update(row).subscribe(
        (story: Story) => gridHolder.updateGridForStatusChange(gridHolder, story),
        (err: any) => gridHolder.processError.call(gridHolder, err));
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
              (err) => gridHolder.processError.call(gridHolder, err));
          }
        },
        (err: any) => gridHolder.processError(err));
    }
  }

  updateGridForStatusChange(gridHolder: StoriesComponent, row: any): void {
    gridHolder.checkRemoveRow(row);
    gridHolder.gridOptions.api.refreshView();
  }

  private addDefaultOptions(): void {
    this.addReleaseOptions(this.releases);
    this.addIterationOptions(this.iterations);
    this.addTeamOptions(this.teams);
    this.addIndividualOptions(this.individuals);
  }

  private setGridHeight(): void {
    $('ag-grid-ng2').height($(window).height() - 84);
  }

  private setAttributes(storyAttributes: StoryAttribute[]): void {
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
      width: 54,
      field: 'blank',
      cellRendererFramework: ButtonBarComponent,
      suppressMovable: true,
      suppressResize: true,
      suppressSorting: true
    }];
    this.filteredAttributes = [];
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
        this.filteredAttributes.push(storyAttribute);
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

  private fetchStoryAttributes(): void {
    this.storyAttributesService.getStoryAttributes()
      .subscribe(
        (storyAttributes: StoryAttribute[]) => this.setAttributes(storyAttributes),
        (err: any) => this.processError(err));
  }

  private fetchProjects(): void {
    this.projectsService.getProjects()
      .subscribe(
        (projects: Project[]) => this.projects = projects,
        (err: any) => this.processError(err));
  }

  private hasCurrentRelease(releases: Release[]): boolean {
    return this.getCurrentRelease(releases) !== null;
  }

  private getCurrentRelease(releases: Release[]): Release {
    releases.forEach((release: Release) => {
      if (release.start && release.finish && release.isCurrent()) {
        return release;
      }
    });
    return null;
  }

  private addReleaseOptions(releases: Release[]): void {
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

  private fetchReleases(): void {
    this.releasesService.getReleases()
      .subscribe(
        (releases: Release[]) => {
          this.addReleaseOptions(releases);
        },
        (err: any) => this.processError(err));
  }

  private hasCurrentIteration(iterations: Iteration[]): boolean {
    return this.getCurrentIteration(iterations) !== null;
  }

  private getCurrentIteration(iterations: Iteration[]): Iteration {
    iterations.forEach((iteration: Iteration) => {
      if (iteration.start && iteration.finish && iteration.isCurrent()) {
        return iteration;
      }
    });
    return null;
  }

  private addIterationOptions(iterations: Iteration[]): void {
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

  private fetchIterations(): void {
    this.iterationsService.getIterations()
      .subscribe(
        (iterations: Iteration[]) => {
          this.addIterationOptions(iterations);
        },
        (err: any) => this.processError(err));
  }

  private addTeamOptions(teams: Team[]): void {
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

  private fetchTeams(): void {
    this.teamsService.getTeams(this.user.selected_project_id)
      .subscribe(
        (teams: Team[]) => {
          this.addTeamOptions(teams);
        },
        (err: any) => this.processError(err));

  }

  private addIndividualOptions(individuals: Individual[]): void {
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

  private fetchIndividuals(): void {
    this.individualsService.getIndividuals()
      .subscribe(
        (individuals: Individual[]) => {
          this.addIndividualOptions(individuals);
        },
        (err: any) => this.processError(err));
  }

  private fetchStories(): void {
    this.storiesService.getStories(this.release, this.iteration, this.team, this.individual, this.status)
      .subscribe(
        (stories: Story[]) => {
          stories.forEach((story: Story) => {
            this.id_map[story.uniqueId] = story;
            story.tasks.forEach((task: Task) => {
              this.id_map[task.uniqueId] = task;
            });
          });
          this.stories = stories;
          if (!this.menusLoaded) {
            this.menusLoaded = true;
            this.fetchMenus();
          }
        },
        (err: any) => this.processError(err));
  }

  private fetchAll(): void {
    this.fetchStories();
    this.fetchStoryAttributes();
  }

  private fetchMenus(): void {
    this.fetchReleases();
    this.fetchIterations();
    this.fetchTeams();
    this.fetchIndividuals();
    this.fetchProjects();
  }

  private processError(error: any): void {
    if (error instanceof Response && error.status === 401 || error.status === 422) {
      this.sessionsService.forceLogin();
    } else {
      this.errorService.showError(this.errorService.getError(error));
    }
  }

  public export() {
    this.storiesService.exportStories(this.release, this.iteration, this.team, this.individual, this.status);
  }

  public import() {
    $('#import').click();
  }
}
