import { Component, AfterViewInit, ViewChild } from '@angular/core';
import { Response } from '@angular/http';
import { Router, ActivatedRoute, Params } from '@angular/router';
import { GridOptions } from 'ag-grid/main';
import { StoryFiltersComponent } from '../story-filters/story-filters.component';
import { StoryActionsComponent } from '../story-actions/story-actions.component';
import { SessionsService } from '../../services/sessions.service';
import { StoryAttributesService } from '../../services/story-attributes.service';
import { ErrorService } from '../../services/error.service';
import { ProjectsService } from '../../services/projects.service';
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
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-stories',
  templateUrl: './stories.component.html',
  styleUrls: ['./stories.component.css'],
  providers: [
    StoriesService, TasksService, StoryAttributesService, ProjectsService]
})
export class StoriesComponent implements AfterViewInit {
  static instance: StoriesComponent;
  private static defaultRelease = 'Current';
  private static defaultIteration = 'Current';
  private static defaultTeam = 'MyTeam';
  private static defaultIndividual = 'All';
  private static defaultStatus = 'NotDone';
  private static noSelection = 'None';
  public gridOptions: GridOptions = <GridOptions>{};
  public columnDefs: any[] = [];
  public stories: Story[] = [];
  public projects: Project[] = [];
  public selection: any = null;
  public user: Individual;
  public waiting: boolean = false;
  public storyAttributes: StoryAttribute[] = [];
  
  @ViewChild(StoryFiltersComponent)
  public filters: StoryFiltersComponent;
  
  private filteredAttributes: StoryAttribute[] = [];
  private menusLoaded: boolean = false;
  private id_map: any = {};
  private refresh_interval = null;
  private selectionChanged: boolean = false;

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private sessionsService: SessionsService,
    private storyAttributesService: StoryAttributesService,
    private projectsService: ProjectsService,
    private storiesService: StoriesService,
    private tasksService: TasksService,
    private errorService: ErrorService
  ) {
    StoriesComponent.instance = this;
  }

  ngAfterViewInit(): void {
    let self = this;
    this.user = new Individual(this.sessionsService.getCurrentUser());
    this.filters.addDefaultOptions(this.user);
    this.setGridHeight();
    $(window).resize(this.setGridHeight);
    this.route.params.subscribe((params:any) => this.applyNavigation(params));
    if(this.user.refresh_interval) {
      this.refresh_interval = setInterval(() => {
        self.refresh();
      }, this.user.refresh_interval);
    }
  }
  
  private applyNavigation(params: any) {
    this.filters.release = params['release'] == null ? StoriesComponent.defaultRelease : params['release'];
    this.filters.iteration = params['iteration'] == null ? StoriesComponent.defaultIteration : params['iteration'];
    this.filters.team = params['team'] == null ? StoriesComponent.defaultTeam : params['team'];
    this.filters.individual = params['individual'] == null ? StoriesComponent.defaultIndividual : params['individual'];
    this.filters.status = params['status'] == null ? StoriesComponent.defaultStatus : params['status'];
    if (!this.selectionChanged) {
      this.fetchAll(params['selection']);
    } else {
      this.selectionChanged = false;
      this.applySelection(params['selection']);
    }
  }
    
  private applySelection(selectionValue) {
    let selection: any = null;
    if(selectionValue == 'NewStory') {
      selection = this.createNewStory();
    } else if(('' + selectionValue).search(/NewTask\{S\d+\}/i) == 0) {
      let story:Story = this.id_map[selectionValue.substring(8, selectionValue.length - 1)];
      if(story) {
        selection = this.createNewTask(story);
      }
    } else {
      selection = this.id_map[selectionValue];
    }
    this.selection = selection ? selection : null;
  }
    
  private createNewStory(): Story {
    let release_id: number = null;
    if (this.filters.release !== 'All' && this.filters.release !== '') {
      release_id = this.filters.release === 'Current' ? this.filters.getCurrentRelease(this.filters.releases).id : parseInt(this.filters.release, 10);
    }
    let iteration_id: number = null;
    if (this.filters.iteration !== 'All' && this.filters.iteration !== '') {
      iteration_id = this.filters.iteration === 'Current' ? this.filters.getCurrentIteration(this.filters.iterations).id : parseInt(this.filters.iteration, 10);
    }
    let team_id: number = null;
    if (this.filters.team !== 'All' && this.filters.team !== '') {
      team_id = this.filters.team === 'MyTeam' ? this.user.team_id : parseInt(this.filters.team, 10);
    }
    return new Story({
      status_code: 0,
      release_id: release_id,
      iteration_id: iteration_id,
      team_id: team_id,
      individual_id: null
    });
  }
  
  private createNewTask(story: Story): Task {
    return new Task({
      story: story,
      story_id: story.id,
      status_code: 0,
      individual_id: null
    });
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

    $('.ag-header-container i.fa').off('click').click(function() {
      self.expandContractAll();
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

  addStory(): void {
    this.updateNavigation('NewStory');
  }

  addTask(story: Story): void {
    this.updateNavigation('NewTask{' + story.uniqueId + '}');
  }

  selectRow(event): void {
    this.updateNavigation(event.data.uniqueId);
  }

  finishedEditing(result: FinishedEditing): void {
    if (this.selection) {
      if (this.selection.added) {
        this.selection.added = false;
        this.addRow(this.selection);
        this.updateRows();
      } else {
        this.checkRemoveRow(this.selection);
        this.gridOptions.api.refreshView();
      }
    }
    switch (result) {
      case FinishedEditing.Next:
        this.updateNavigation(this.next() ? this.next().uniqueId : StoriesComponent.noSelection);
        break;
      case FinishedEditing.Previous:
        this.updateNavigation(this.previous() ? this.previous().uniqueId : StoriesComponent.noSelection);
        break;
      case FinishedEditing.AddAnother:
        if (this.selection.isStory()) {
          this.addStory();
        } else {
          this.addTask(this.selection.story);
        }
        break;
      case FinishedEditing.Save:
      case FinishedEditing.Cancel:
        this.updateNavigation(StoriesComponent.noSelection);
        break;
    }
  }

  previous(): any {
    if (this.selection) {
      if (this.selection.isStory()) {
        let index: number = this.stories.indexOf(this.selection);
        if (index > 0) {
          let story: Story = this.stories[index - 1];
          if (story.expanded && story.tasks.length > 0) {
            return story.tasks[story.tasks.length - 1];
          } else {
            return story;
          }
        }
      } else {
        let index: number = this.selection.story.tasks.indexOf(this.selection);
        if (index > 0) {
          return this.selection.story.tasks[index - 1];
        } else {
          return this.selection.story;
        }
      }
    }
    return null;
  }

  next(): any {
    if (this.selection) {
      if (this.selection.isStory()) {
        if (this.selection.expanded && this.selection.tasks.length > 0) {
          return this.selection.tasks[0];
        } else {
          let index: number = this.stories.indexOf(this.selection);
          if (index < this.stories.length - 1) {
            return this.stories[index + 1];
          }
        }
      } else {
        let index: number = this.selection.story.tasks.indexOf(this.selection);
        if (index < this.selection.story.tasks.length - 1) {
          return this.selection.story.tasks[index + 1];
        } else {
          index = this.stories.indexOf(this.selection.story);
          if (index < this.stories.length - 1) {
            return this.stories[index + 1];
          }
        }
      }
    }
    return null;
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

  getRowClass(rowItem: any): string {
    return (rowItem.data.isStory() ? 'story' : 'task') + ' id-' + rowItem.data.uniqueId;
  }

  getRowNodeId(rowItem): string {
    return rowItem.uniqueId;
  }

  dropRow(event, ui): void {
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
    self.updateRows();
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
      if (this.filters.release !== 'All') {
        if (this.filters.release === '') {
          filtered = filtered || row.release_id;
        } else if (this.filters.release === 'Current') {
          filtered = filtered || (row.release_id !== this.filters.getCurrentRelease(this.filters.releases));
        } else {
          filtered = filtered || (row.release_id !== this.filters.release);
        }
      }
      if (this.filters.iteration !== 'All') {
        if (this.filters.iteration === '') {
          filtered = filtered || row.iteration_id;
        } else if (this.filters.iteration === 'Current') {
          filtered = filtered || (row.iteration_id !== this.filters.getCurrentIteration(this.filters.iterations));
        } else {
          filtered = filtered || (row.iteration_id !== this.filters.iteration);
        }
      }
      if (this.filters.team !== 'All') {
        if (this.filters.team === '') {
          filtered = filtered || row.team_id;
        } else if (this.filters.team === 'MyTeam') {
          filtered = filtered || (row.team_id !== this.user.team_id);
        } else {
          filtered = filtered || (row.team_id !== this.filters.team);
        }
      }
      if (this.filters.individual !== 'All') {
        if (this.filters.individual === '') {
          filtered = filtered || row.individual_id;
        } else {
          filtered = filtered || (row.individual_id !== this.filters.individual);
        }
      }
    }
    if (this.filters.status !== 'All') {
      if (this.filters.status === 'NotDone') {
        filtered = filtered || (row.status_code === 3);
      } else {
        filtered = filtered || (row.status_code !== this.filters.status);
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
      this.updateExpandContractAll();
    }
    this.storiesService.setRanks(this.stories);
  }

  getIndex(objects: any[], id: number): number {
    let index: number = -1;
    let i = 0;
    objects.forEach((object: any) => {
      if (('' + object.id) === ('' + id)) {
        index = i;
      }
      i++;
    });
    return index;
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

  private setGridHeight(): void {
    $('ag-grid-ng2').height($(window).height() - 84);
  }

  setAttributes(storyAttributes: StoryAttribute[]): void {
    this.storyAttributes = storyAttributes;
    let newColumnDefs: any[] = [{
      headerName: '',
      width: 20,
      field: 'blank',
      headerCellTemplate: this.getGroupHeader,
      cellRenderer: 'group',
      suppressMovable: true,
      suppressResize: true,
      suppressSorting: true
    }, {
      headerName: '',
      width: 54,
      field: 'blank',
      cellRendererFramework: StoryActionsComponent,
      suppressMovable: true,
      suppressResize: true,
      suppressSorting: true
    }];
    this.filteredAttributes = [];
    storyAttributes.forEach((storyAttribute: StoryAttribute) => {
      if (storyAttribute.show &&
        (this.filters.release === 'All' || storyAttribute.name !== 'Release') &&
        (this.filters.iteration === 'All' || storyAttribute.name !== 'Iteration') &&
        (this.filters.team === 'All' || storyAttribute.name !== 'Team')) {
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

  private getGroupHeader(): string {
    return '<i class="fa fa-plus-square-o" aria-hidden="true"></i>';
  }

  private storiesToExpand(): boolean {
    let storiesToExpand = false;
    this.stories.forEach((story: Story) => {
      if (!story.expanded) {
        storiesToExpand = true;
      }
    });
    return storiesToExpand;
  }

  private expandContractAll(): void {
    let shouldExpand = this.storiesToExpand();
    this.stories.forEach((story: Story) => {
      story.expanded = shouldExpand;
    });
    this.updateRows();
  }

  updateRows() {
    this.gridOptions.api.setRowData(this.stories);
    this.updateExpandContractAll();
  }

  updateExpandContractAll(): void {
    if (StoriesComponent.instance.storiesToExpand()) {
      $('.ag-header-container i.fa').removeClass('fa-minus-square-o').addClass('fa-plus-square-o');
    } else {
      $('.ag-header-container i.fa').removeClass('fa-plus-square-o').addClass('fa-minus-square-o');
    }
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

  updateNavigation(selection?: any): void {
    let params = {};
    if (this.filters.release !== StoriesComponent.defaultRelease) {
      params['release'] = this.filters.release;
    }
    if (this.filters.iteration !== StoriesComponent.defaultIteration) {
      params['iteration'] = this.filters.iteration;
    }
    if (this.filters.team !== StoriesComponent.defaultTeam) {
      params['team'] = this.filters.team;
    }
    if (this.filters.individual !== StoriesComponent.defaultIndividual) {
      params['individual'] = this.filters.individual;
    }
    if (this.filters.status !== StoriesComponent.defaultStatus) {
      params['status'] = this.filters.status;
    }
    if (selection) {
      this.selectionChanged = true;
      if(selection !== StoriesComponent.noSelection) {
        params['selection'] = selection;
      }
    }
    this.router.navigate(['stories', params]);
  }

  fetchStories(selection?: any): void {
    this.waiting = true;
    this.storiesService.getStories(this.filters.release, this.filters.iteration, this.filters.team, this.filters.individual, this.filters.status)
      .subscribe(
        (stories: Story[]) => {
          stories.forEach((story: Story) => {
            this.id_map[story.uniqueId] = story;
            story.tasks.forEach((task: Task) => {
              this.id_map[task.uniqueId] = task;
            });
          });
          this.stories = stories;
          this.updateExpandContractAll();
          if(selection) {
            this.applySelection(selection);
          }
          this.waiting = false;
          if (!this.menusLoaded) {
            this.menusLoaded = true;
            this.fetchMenus();
          }
        },
        (err: any) => this.processError(err));
  }

  refresh(): void {
    if (!this.selection) { // Don't blow away current edits
      this.menusLoaded = false; // Force reload
      this.fetchAll();
    }
  }

  private fetchAll(selection?: any): void {
    this.fetchStories(selection);
    this.fetchStoryAttributes();
  }

  private fetchMenus(): void {
    this.filters.fetchMenus(this.user);
    this.fetchProjects();
  }

  private processError(error: any): void {
    if (error instanceof Response && error.status === 401 || error.status === 422) {
      this.sessionsService.forceLogin();
    } else {
      this.errorService.showError(this.errorService.getError(error));
    }
  }
}
