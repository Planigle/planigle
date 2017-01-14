import { Component, AfterViewInit, OnDestroy, ViewChild } from '@angular/core';
import { Response } from '@angular/http';
import { Router, ActivatedRoute } from '@angular/router';
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
import { Work } from '../../models/work';
import { Story } from '../../models/story';
import { Task } from '../../models/task';
import { Project } from '../../models/project';
import { Individual } from '../../models/individual';
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-stories',
  templateUrl: './stories.component.html',
  styleUrls: ['./stories.component.css'],
  providers: [StoriesService, TasksService, StoryAttributesService, ProjectsService]
})
export class StoriesComponent implements AfterViewInit, OnDestroy {
  private static noSelection = 'None';
  public gridOptions: GridOptions = <GridOptions>{};
  public columnDefs: any[] = [];
  public stories: Story[] = [];
  public projects: Project[] = [];
  public selection: Work = null;
  public user: Individual;
  public waiting: boolean = false;
  public storyAttributes: StoryAttribute[] = [];
  public customStoryAttributes: StoryAttribute[] = [];
  public selectedWork: Work[] = [];

  @ViewChild(StoryFiltersComponent)
  public filters: StoryFiltersComponent;

  private filteredAttributes: StoryAttribute[] = [];
  private menusLoaded: boolean = false;
  private id_map: Map<string, Work> = new Map();
  private refresh_interval = null;
  private selectionChanged: boolean = false;
  private lastSelected: Work = null;

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private sessionsService: SessionsService,
    private storyAttributesService: StoryAttributesService,
    private projectsService: ProjectsService,
    private storiesService: StoriesService,
    private tasksService: TasksService,
    private errorService: ErrorService
  ) {}

  ngAfterViewInit(): void {
    let self = this;
    this.user = new Individual(this.sessionsService.getCurrentUser());
    this.filters.addDefaultOptions(this.user);
    this.setGridHeight();
    $(window).resize(this.setGridHeight);
    this.fetchStoryAttributes();
    this.route.params.subscribe((params: Map<string, string>) => this.applyNavigation(params));
    if (this.user.refresh_interval) {
      this.refresh_interval = setInterval(() => {
        self.refresh();
      }, this.user.refresh_interval);
    }
  }

  ngOnDestroy(): void {
    if (this.refresh_interval) {
      clearInterval(this.refresh_interval);
    }
    $(window).off('resize');
  }

  private applyNavigation(params: Map<string, string>) {
    this.filters.applyNavigation(params);
    if (!this.selectionChanged) {
      this.fetchStories(params['selection']);
    } else {
      this.selectionChanged = false;
      this.applySelection(params['selection']);
    }
  }

  private applySelection(selectionValue) {
    let selection: Work = null;
    if (selectionValue === 'NewStory') {
      selection = this.createNewStory();
    } else if (('' + selectionValue).search(/NewTask\{S\d+\}/i) === 0) {
      let story: Story = this.id_map[selectionValue.substring(8, selectionValue.length - 1)];
      if (story) {
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
      release_id = this.filters.release === 'Current' ? this.filters.getCurrentReleaseId(this.filters.releases) :
        parseInt(this.filters.release, 10);
    }
    let iteration_id: number = null;
    if (this.filters.iteration !== 'All' && this.filters.iteration !== '') {
      iteration_id = this.filters.iteration === 'Current' ? this.filters.getCurrentIterationId(this.filters.iterations) :
        parseInt(this.filters.iteration, 10);
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

  updateNewStoryReleaseId(currentReleaseId: number) {
    // Needed to handle case where initially loading new story with current release
    if (this.selection && this.selection.isStory() && !this.selection.id) {
      this.selection = this.createNewStory();
    }
  }

  updateNewStoryIterationId(currentIterationId: number) {
    // Needed to handle case where initially loading new story with current iteration
    if (this.selection && this.selection.isStory() && !this.selection.id) {
      this.selection = this.createNewStory();
    }
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
      drop: function(event, ui) {
        self.dropRow(event, ui);
      },
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
      drop: function(event, ui) {
        self.dropRow(event, ui);
      },
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

  getChildren(rowItem: Story): any {
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

  deleteWork(work: Work): void {
    let service: any = work.isStory() ? this.storiesService : this.tasksService;
    service.delete.call(service, work).subscribe(
      (task: any) => {
        this.selection = work;
        this.selection.deleted = true;
        this.finishedEditing(FinishedEditing.Cancel);
        this.selection = null;
      }
    );
  }

  selectRow(event: any): void {
    if (event.colDef.headerName === '') {
      return;
    }
    let mouseEvent = event.event;
    let work: Work = event.data;
    if (mouseEvent.ctrlKey || mouseEvent.metaKey) {
      this.flipSelection(work);
    } else if (this.lastSelected !== null && mouseEvent.shiftKey) {
      let visibleWork: Work[] = this.getVisibleWork();
      let startIndex: number = visibleWork.indexOf(this.lastSelected);
      let endIndex: number = visibleWork.indexOf(work);
      if (endIndex < startIndex) {
        let temp: number = startIndex;
        startIndex = endIndex;
        endIndex = temp - 1;
      } else {
        startIndex += 1;
      }
      for (let i = startIndex; i <= endIndex; i++) {
        this.flipSelection(visibleWork[i]);
      }
    } else {
      let previousSelected: boolean = this.isSelected(work);
      this.selectedWork.forEach((previousWork: Work) => {
        let row = $('.ag-row.id-' + previousWork.uniqueId);
        row.removeClass('selected');
      });
      this.selectedWork = [];
      if (!previousSelected) {
        let row = $('.ag-row.id-' + work.uniqueId);
        row.addClass('selected');
        this.selectedWork.push(work);
      }
    }
    this.lastSelected = work;
  }

  private getVisibleWork(): Work[] {
    let visibleWork: Work[] = [];
    let rows: any[] = this.gridOptions.api.getRenderedNodes();
    for (let i = 0; i < rows.length; i++) {
      visibleWork.push(rows[i].data);
    }
    return visibleWork;
  }

  private flipSelection(work: Work): void {
    let row = $('.ag-row.id-' + work.uniqueId);
    if (this.isSelected(work)) {
      row.removeClass('selected');
      this.selectedWork.splice(this.selectedWork.indexOf(work), 1);
    } else {
      row.addClass('selected');
      this.selectedWork.push(work);
    }
  }

  isSelected(work: Work): boolean {
    return this.selectedWork.indexOf(work) !== -1;
  }

  editRow(event): void {
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
        this.refreshView();
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
          let task: Task = <Task> this.selection;
          this.addTask(task.story);
        }
        break;
      case FinishedEditing.Save:
      case FinishedEditing.Cancel:
        this.updateNavigation(StoriesComponent.noSelection);
        break;
    }
  }

  previous(): Work {
    if (this.selection) {
      if (this.selection.isStory()) {
        let index: number = this.stories.indexOf(<Story> this.selection);
        if (index > 0) {
          let story: Story = this.stories[index - 1];
          if (story.expanded && story.tasks.length > 0) {
            return story.tasks[story.tasks.length - 1];
          } else {
            return story;
          }
        }
      } else {
        let task: Task = <Task> this.selection;
        let index: number = task.story.tasks.indexOf(task);
        if (index > 0) {
          return task.story.tasks[index - 1];
        } else {
          return task.story;
        }
      }
    }
    return null;
  }

  next(): Work {
    if (this.selection) {
      if (this.selection.isStory()) {
        let story: Story = <Story> this.selection;
        if (story.expanded && story.tasks.length > 0) {
          return story.tasks[0];
        } else {
          let index: number = this.stories.indexOf(story);
          if (index < this.stories.length - 1) {
            return this.stories[index + 1];
          }
        }
      } else {
        let task: Task = <Task> this.selection;
        let index: number = task.story.tasks.indexOf(task);
        if (index < task.story.tasks.length - 1) {
          return task.story.tasks[index + 1];
        } else {
          index = this.stories.indexOf(task.story);
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
          .subscribe((result) => this.sortCustomStoryAttributes());
      }
    }
  }

  private sortCustomStoryAttributes(): void {
    this.customStoryAttributes.sort((v1: StoryAttribute, v2: StoryAttribute) => {
      if (v1.ordering < v2.ordering) {
        return -1;
      }
      if (v2.ordering < v1.ordering) {
        return 1;
      }
      return 0;
    });
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

  private getRowWork(jQueryObject: any): Work {
    let result: string = null;
    $.each(jQueryObject.attr('class').toString().split(' '), function (i: number, className: string) {
      if (className.indexOf('id-') === 0) {
        result = className.substring(3);
      }
    });
    return this.id_map[result];
  }

  dropRow(event, ui): void {
    let movedRow: Work = this.getRowWork($(ui.draggable[0]));
    let targetRow: Work = this.getRowWork($(this));
    if (movedRow.isStory()) {
      // Move story
      let story: Story = <Story> movedRow;
      let targetStory: Story = null;
      if (targetRow && !targetRow.isStory()) {
        // If moving story to task, move after story for task
        let task: Task = <Task> targetRow;
        let index = this.stories.indexOf(task.story) + 1;
        if (index >= this.stories.length) {
          targetStory = null;
        } else {
          targetStory = this.stories[index];
        }
      } else {
        targetStory = <Story> targetRow;
      }
      this.stories.splice(this.stories.indexOf(story), 1);
      if (targetStory) {
        this.stories.splice(this.stories.indexOf(targetStory), 0, story);
      } else {
        this.stories.push(story);
      }
      story.priority = this.determinePriority(this.stories, story);
      this.storiesService.update(story).subscribe((story) => {}, (error) => this.processError.call(this, error));
    } else {
      // Move task
      let task: Task = <Task> movedRow;
      let oldStory: Story = task.story;
      oldStory.tasks.splice(oldStory.tasks.indexOf(task), 1);
      let index: number = targetRow && targetRow.isStory() ? this.stories.indexOf(<Story> targetRow) : -1;
      let newStory: Story = targetRow ?
        (targetRow.isStory() ? (this.stories[index === 0 ? 0 : index - 1]) : (<Task> targetRow).story) :
        this.stories[this.stories.length - 1];
      if (oldStory.id !== newStory.id) {
        task.story = newStory;
        task.previous_story_id = oldStory.id;
        task.story_id = newStory.id;
      }
      if (targetRow && !targetRow.isStory()) {
        // Moving to within tasks
        newStory.tasks.splice(newStory.tasks.indexOf(<Task> targetRow), 0, task);
      } else {
        // Moving to end of tasks
        newStory.tasks.push(task);
      }
      task.priority = this.determinePriority(newStory.tasks, task);
      this.tasksService.update(task)
        .subscribe((task) => task.previous_story_id = null, (error) => this.processError.call(this, error));
      newStory.expanded = true;
    }
    this.updateRows();
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

  private addRow(row: Work): void {
    this.id_map[row.uniqueId] = row;
    if (row.isStory()) {
      this.stories.push(<Story> row);
      this.storiesService.setRanks(this.stories);
    } else {
      this.stories.forEach((story: Story) => {
        if (story.id === row.story_id) {
          story.expanded = true;
          story.tasks.push(<Task> row);
        }
      });
    }
  }

  checkRemoveRow(row: Work): void {
    let filtered = false;
    if ( row.deleted ) {
      filtered = true;
    } else if (row.isStory()) {
      let story: Story = <Story> row;
      if (this.filters.release !== 'All') {
        if (this.filters.release === '') {
          filtered = filtered || (story.release_id != null);
        } else if (this.filters.release === 'Current') {
          filtered = filtered || (story.release_id !== this.filters.getCurrentReleaseId(this.filters.releases));
        } else {
          filtered = filtered || (story.release_id !== this.filters.release);
        }
      }
      if (this.filters.iteration !== 'All') {
        if (this.filters.iteration === '') {
          filtered = filtered || (story.iteration_id != null);
        } else if (this.filters.iteration === 'Current') {
          filtered = filtered || (story.iteration_id !== this.filters.getCurrentIterationId(this.filters.iterations));
        } else {
          filtered = filtered || (story.iteration_id !== this.filters.iteration);
        }
      }
      if (this.filters.team !== 'All') {
        if (this.filters.team === '') {
          filtered = filtered || (story.team_id != null);
        } else if (this.filters.team === 'MyTeam') {
          filtered = filtered || (story.team_id !== this.user.team_id);
        } else {
          filtered = filtered || (story.team_id !== this.filters.team);
        }
      }
      if (this.filters.individual !== 'All') {
        if (this.filters.individual === '') {
          filtered = filtered || (story.individual_id != null);
        } else {
          filtered = filtered || (story.individual_id !== this.filters.individual);
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

  private statusChanged(gridHolder: StoriesComponent, row: Work): void {
    if (row.isStory()) {
      gridHolder.storiesService.update(<Story> row).subscribe(
        (story: Story) => gridHolder.updateGridForStatusChange(story),
        (err: any) => gridHolder.processError.call(gridHolder, err));
    } else {
      let changedTask: Task = <Task> row;
      gridHolder.tasksService.update(changedTask).subscribe(
        (task: Task) => {
          gridHolder.updateGridForStatusChange(task);
          let statusChanged = false;
          if (changedTask.status_code === 2 && changedTask.story.status_code !== 2) {
            changedTask.story.status_code = 2;
            statusChanged = true;
          } else if (changedTask.status_code > 0 && changedTask.story.status_code === 0) {
            changedTask.story.status_code = 1;
            statusChanged = true;
          }
          if (statusChanged) {
            gridHolder.storiesService.update(changedTask.story).subscribe(
              (story: Story) => gridHolder.updateGridForStatusChange(changedTask.story),
              (err) => gridHolder.processError.call(gridHolder, err));
          }
        },
        (err: any) => gridHolder.processError(err));
    }
  }

  updateGridForStatusChange(row: Work): void {
    this.checkRemoveRow(row);
    this.refreshView();
  }

  refreshView(): void {
    this.gridOptions.api.refreshView();
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
    }];
    if (this.user.canChangeBacklog()) {
      newColumnDefs.push({
        headerName: '',
        width: 54,
        field: 'blank',
        cellRendererFramework: StoryActionsComponent,
        suppressMovable: true,
        suppressResize: true,
        suppressSorting: true
      });
    }
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
    this.updateCustomStoryAttributes();
    this.columnDefs = newColumnDefs;
  }

  private updateCustomStoryAttributes(): void {
    let filtered: StoryAttribute[] = [];
    this.storyAttributes.forEach((storyAttribute: StoryAttribute) => {
      if (storyAttribute.is_custom) {
        filtered.push(storyAttribute);
      }
    });
    this.customStoryAttributes = filtered;
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
    if (this.storiesToExpand()) {
      $('.ag-header-container i.fa').removeClass('fa-minus-square-o').addClass('fa-plus-square-o');
    } else {
      $('.ag-header-container i.fa').removeClass('fa-plus-square-o').addClass('fa-minus-square-o');
    }
  }

  private fetchStoryAttributes(ignoreErrors?: boolean): void {
    this.storyAttributesService.getStoryAttributes()
      .subscribe(
        (storyAttributes: StoryAttribute[]) => this.setAttributes(storyAttributes),
        (err: any) => {
          if (!ignoreErrors) {
            this.processError(err);
          }
        });
  }

  private fetchProjects(): void {
    this.projectsService.getProjects()
      .subscribe(
        (projects: Project[]) => this.projects = projects,
        (err: any) => this.processError(err));
  }

  updateNavigation(selection?: String): void {
    let params: Map<string, string> = new Map();
    this.filters.updateNavigationParams(params);
    if (selection) {
      this.selectionChanged = true;
      if (selection !== StoriesComponent.noSelection) {
        params['selection'] = selection;
      }
    }
    this.router.navigate(['stories', params]);
  }

  fetchStories(selection?: Work, ignoreErrors?: boolean): void {
    this.waiting = true;
    this.storiesService.getStories(this.filters.queryString)
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
          if (selection) {
            this.applySelection(selection);
          }
          this.waiting = false;
          if (!this.menusLoaded) {
            this.menusLoaded = true;
            this.fetchMenus();
          }
        },
        (err: any) => {
          if (!ignoreErrors) {
            this.processError(err);
          }
        });
  }

  refresh(): void {
    if (!this.selection) { // Don't blow away current edits
      this.menusLoaded = false; // Force reload
      this.fetchAll(true);
    }
  }

  private fetchAll(ignoreErrors?: boolean): void {
    this.fetchStories(null, ignoreErrors);
    this.fetchStoryAttributes(ignoreErrors);
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
