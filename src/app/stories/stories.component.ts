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

  ngOnInit() {
    this.user = new Individual(this.sessionsService.getCurrentUser());
    this.addDefaultOptions();
    this.fetchAll();
    this.setGridHeight();
    $(window).resize(this.setGridHeight);
  }

  gridReady() {
    let self = this;
    let interval = null;
    const scrollAmount = 150;
    $('.ag-row').draggable({
      appendTo: '.ag-body-viewport',
      zIndex: 100,
      axis: 'y',
      helper: 'clone',
      revert: 'invalid',
    }).droppable({
      drop: self.dropRow,
      tolerance: 'pointer'
    });
    $('.scroll-up').droppable({
      over: function(event, ui){
        interval = setInterval(function() {
          let scroll = $('.ag-body-viewport').scrollTop();
          let diff = scroll < scrollAmount ? -scroll : -scrollAmount;
          if (diff < 0) {
            $('.ag-body-viewport').scrollTop(scroll + diff);
          }
        }, 200);
      },
      out: function(event, ui){
        if (interval !== null) {
          clearInterval(interval);
          interval = null;
        }
      }
    });

    $('.scroll-down').droppable({
      drop: self.dropRow,
      over: function(event, ui){
        interval = setInterval(function() {
          let scroll = $('.ag-body-viewport').scrollTop();
          let maxScroll = $('.ag-body-viewport').prop('scrollHeight') - $('.ag-body-viewport').innerHeight();
          let diff = scroll + scrollAmount > maxScroll ? (maxScroll - scrollAmount) : scrollAmount;
          if (diff > 0) {
            $('.ag-body-viewport').scrollTop(scroll + diff);
          }
        }, 200);
      },
      out: function(event, ui){
        if (interval !== null) {
          clearInterval(interval);
          interval = null;
        }
      }
    });
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

  addStory() {
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

  selectRow(event) {
    this.selection = event.data;
  }

  clearSelection() {
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

  moveColumn(event) {
    let storyAttribute = event.column.colDef.storyAttribute;
    if (storyAttribute) {
      let oldIndex = this.getIndex(this.filteredAttributes, storyAttribute.id);
      let newIndex = event.toIndex - 2; // ignore first columns;
      newIndex = newIndex < 0 ? 0 : newIndex;
      if (oldIndex !== newIndex) {
        let min = newIndex < oldIndex ?
          (newIndex === 0 ?
            this.filteredAttributes[0].ordering - 20 :
            this.filteredAttributes[newIndex - 1].ordering) :
          this.filteredAttributes[newIndex].ordering;
        let max = newIndex > oldIndex ?
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

  resizeColumn(event) {
    let storyAttribute = event.column.colDef.storyAttribute;
    if (storyAttribute) {
      storyAttribute.width = event.column.actualWidth;
      this.storyAttributesService.update(storyAttribute)
        .subscribe((result) => {});
    }
  }

  public getRowClass(rowItem) {
    return (rowItem.data.isStory() ? 'story' : 'task') + ' id-' + rowItem.data.uniqueId;
  }

  public getRowNodeId(rowItem) {
    return rowItem.uniqueId;
  }

  public dropRow(event, ui) {
    let self = StoriesComponent.instance;
    function getRow(jQueryObject) {
      let result = null;
      $.each($(jQueryObject).attr('class').toString().split(' '), function (i, className) {
        if (className.indexOf('id-') === 0) {
          result = className.substring(3);
        }
      });
      return self.id_map[result];
    }

    let movedRow = getRow(ui.draggable[0]);
    let targetRow = getRow(this);
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
      self.storiesService.update(movedRow).subscribe((story) => {}, (error) => self.processRemoteError(self, error));
    } else {
      // Move task
      let oldStory = movedRow.story;
      oldStory.tasks.splice(oldStory.tasks.indexOf(movedRow), 1);
      let index = targetRow ? self.stories.indexOf(targetRow) : -1;
      let newStory = targetRow ?
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
        .subscribe((task) => movedRow.previous_story_id = null, (error) => self.processRemoteError(self, error));
      newStory.expanded = true;
    }
    self.gridOptions.api.setRowData(self.stories);
  }

  private determinePriority(objects, object): number {
    //  Return a number between the priorities of the surrounding elements
    if (objects.length === 1) {
      return 10;
    } else {
      let index = objects.indexOf(object);
      let min = index === 0 ? objects[index + 1].priority - 20 : objects[index - 1].priority;
      let max = index === objects.length - 1 ? objects[objects.length - 2].priority + 20 : objects[index + 1].priority;
      return min + ((max - min) / 2);
    }
  }

  private addRow(row) {
    this.id_map[row.uniqueId] = row;
    if (row.isStory()) {
      this.stories.push(row);
      this.storiesService.setRanks(this.stories);
    } else {
      this.stories.forEach((story) => {
        if (story.id === row.story_id) {
          story.expanded = true;
          story.tasks.push(row);
        }
      });
    }
  }

  private checkRemoveRow(row) {
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
      if (release.start && release.finish && release.isCurrent()) {
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
      if (iteration.start && iteration.finish && iteration.isCurrent()) {
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
          stories.forEach((story) => {
            this.id_map[story.uniqueId] = story;
            story.tasks.forEach((task) => {
              this.id_map[task.uniqueId] = task;
            });
          });
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
