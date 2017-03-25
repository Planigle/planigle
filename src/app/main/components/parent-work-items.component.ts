import { Component, OnInit, AfterViewInit, OnDestroy, ViewChild } from '@angular/core';
import { Response } from '@angular/http';
import { Router, ActivatedRoute } from '@angular/router';
import { GridOptions } from 'ag-grid/main';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { ConfirmationDialogComponent } from './confirmation-dialog/confirmation-dialog.component';
import { StoryFiltersComponent } from './story-filters/story-filters.component';
import { GroupHeaderComponent } from './group-header/group-header.component';
import { PremiumReportsComponent } from '../../premium/components/premium-reports/premium-reports.component';
import { SessionsService } from '../services/sessions.service';
import { StoryAttributesService } from '../services/story-attributes.service';
import { ProjectionsService } from '../../premium/services/projections.service';
import { ErrorService } from '../services/error.service';
import { ProjectsService } from '../services/projects.service';
import { StoriesService } from '../services/stories.service';
import { TasksService } from '../services/tasks.service';
import { DragDropService } from '../services/drag-drop.service';
import { StoryAttribute } from '../models/story-attribute';
import { Work } from '../models/work';
import { Story } from '../models/story';
import { Task } from '../models/task';
import { Project } from '../models/project';
import { Team } from '../models/team';
import { Individual } from '../models/individual';
import { FinishedEditing } from '../models/finished-editing';
declare var $: any;

export abstract class ParentWorkItemsComponent implements OnInit, AfterViewInit, OnDestroy {
  private static instance: ParentWorkItemsComponent;
  private static noSelection = 'None';
  public gridOptions: GridOptions = <GridOptions>{};
  public columnDefs: any[] = [];
  public currentPage: number = 1;
  public numPages: number = 1;
  public stories: Story[] = [];
  public epics: Story[] = [];
  public projects: Project[] = [];
  public selection: Work = null;
  public split: boolean = false;
  public user: Individual;
  public waiting: boolean = false;
  public storyAttributes: StoryAttribute[] = [];
  public customStoryAttributes: StoryAttribute[] = [];
  public selectedWork: Work[] = [];
  public velocityAllocation: Map<Team, number> = new Map<Team, number>();
  public storyAllocation: Map<Team, number> = new Map<Team, number>();

  @ViewChild(StoryFiltersComponent)
  public filters: StoryFiltersComponent;

  private filteredAttributes: StoryAttribute[] = [];
  private menusLoaded: boolean = false;
  private id_map: Map<string, Work> = new Map();
  private refresh_interval = null;
  private selectionChanged: boolean = false;
  private lastSelected: Work = null;
  private currentParams: Map<string, string>;

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private modalService: NgbModal,
    private sessionsService: SessionsService,
    private storyAttributesService: StoryAttributesService,
    protected projectsService: ProjectsService,
    protected storiesService: StoriesService,
    private tasksService: TasksService,
    private projectionsService: ProjectionsService,
    private dragDropService: DragDropService,
    private errorService: ErrorService
  ) {
    ParentWorkItemsComponent.instance = this;
  }

  abstract getRoute(): string;
  abstract showEpics(): boolean;

  ngOnInit(): void {
    this.user = new Individual(this.sessionsService.getCurrentUser());
  }

  ngAfterViewInit(): void {
    let self = this;
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
    this.currentParams = params;
    this.filters.applyNavigation(params);
    if (!this.selectionChanged) {
      this.fetchStories(params['selection'], false, params['split']);
    } else {
      this.selectionChanged = false;
      this.applySelection(params['selection'], params['split']);
      this.gridReady();
    }
  }

  private applySelection(selectionValue, split?: boolean) {
    this.split = false;
    let selection: Work = null;
    if (selectionValue === 'NewStory') {
      selection = this.createNewStory();
    } else if (('' + selectionValue).search(/NewStory\{S\d+\}/i) === 0) {
      let story: Story = this.id_map[selectionValue.substring(9, selectionValue.length - 1)];
      if (story) {
        selection = this.createNewStory(story);
      }
    } else if (('' + selectionValue).search(/NewTask\{S\d+\}/i) === 0) {
      let story: Story = this.id_map[selectionValue.substring(8, selectionValue.length - 1)];
      if (story) {
        selection = this.createNewTask(story);
      }
    } else {
      selection = this.id_map[selectionValue];
      this.split = split;
    }
    this.selection = selection ? selection : null;
  }

  private createNewStory(epic?: Story): Story {
    let release_id: number = null;
    if (!this.showEpics() && this.filters.release !== 'All' && this.filters.release !== '') {
      release_id = this.filters.release === 'Current' ? this.filters.getCurrentReleaseId(this.filters.releases) :
        parseInt(this.filters.release, 10);
    }
    let iteration_id: number = null;
    if (!this.showEpics() && this.filters.iteration !== 'All' && this.filters.iteration !== '') {
      iteration_id = this.filters.iteration === 'Current' ? this.filters.getCurrentIterationId(this.filters.iterations) :
        parseInt(this.filters.iteration, 10);
    }
    let team_id: number = null;
    if (this.filters.team !== 'All' && this.filters.team !== '') {
      team_id = this.filters.team === 'MyTeam' ? this.user.team_id : parseInt(this.filters.team, 10);
    }
    return new Story({
      status_code: 0,
      project_id: this.user.selected_project_id,
      release_id: release_id,
      iteration_id: iteration_id,
      team_id: team_id,
      story_id: epic ? epic.id : null,
      epic: epic,
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
    this.dragDropService.setUpDragDrop(this, this.dropRow, true);

    $.contextMenu('destroy');
    $.contextMenu(this.getStoryMenu(true));
    $.contextMenu(this.getStoryMenu(false));
    $.contextMenu(this.getTaskMenu());

    let self: ParentWorkItemsComponent = this;
    $('.ag-header-container i.fa').off('click').click(function() {
      self.expandContractAll();
    });
  }

  private getStoryMenu(canAddChildren: boolean): any {
    let self: ParentWorkItemsComponent = this;
    let menu = {
      selector: canAddChildren ? '.story-children' : '.story-no-children',
      items: {
        edit: {
        name: 'Edit',
          callback: function(key, opt) { self.editItem(self.getRowWork(this)); }
        }
      }
    };
    if (this.user.canChangeBacklog()) {
      menu['items']['deleteItem'] = {
        name: 'Delete',
        callback: function(key, opt) { self.deleteItem(self.getRowWork(this)); }
      };
      if (canAddChildren) {
        menu['items']['addChild'] = {
          name: this.showEpics() ? 'Add Story' : 'Add Task',
          callback: function(key, opt) { self.addChildItem(self.getRowWork(this)); }
        };
      }
      menu['items']['split'] = {
        name: 'Split',
        callback: function(key, opt) { self.splitItem(self.getRowWork(this)); }
      };
    }
    return menu;
  }

  private getTaskMenu(): any {
    let self: ParentWorkItemsComponent = this;
    let menu: any = {
      selector: '.task',
      items: {
        edit: {
          name: 'Edit',
          callback: function(key, opt) { self.editItem(self.getRowWork(this)); }
        }
      }
    };
    if (this.user.canChangeBacklog()) {
      menu['items']['deleteItem'] = {
        name: 'Delete',
        callback: function(key, opt) { self.deleteItem(self.getRowWork(this)); }
      };
    }
    return menu;
  }

  editItem(model: Work): void {
    this.updateNavigation(model.uniqueId);
  }

  deleteItem(model: Work): void {
    let self: ParentWorkItemsComponent = this;
    const modalRef: NgbModalRef = this.modalService.open(ConfirmationDialogComponent);
    let typeOfObject: string = model.isStory() ? 'Story' : 'Task';
    let component: ConfirmationDialogComponent = modalRef.componentInstance;
    component.confirmDelete(typeOfObject, model.name);
    modalRef.result.then(
      (result: any) => {
        if (component.model.confirmed) {
          self.deleteWork(model);
        }
      }
    );
  }

  addChildItem(model: Work): void {
    this.addChild(<Story> model);
  }

  splitItem(model: Work): void {
    this.updateNavigation(model.uniqueId, true);
  }

  getChildren(rowItem: Story): any {
    if (rowItem.stories && rowItem.stories.length > 0) {
      return {
        group: true,
        children: rowItem.stories,
        expanded: rowItem.expanded
      };
    } else if (!ParentWorkItemsComponent.instance.showEpics() && rowItem.tasks && rowItem.tasks.length > 0) {
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
    this.expandWork(event.node.data, event.node.expanded);
  }

  addStory(): void {
    this.updateNavigation('NewStory');
  }

  addChild(story: Story): void {
    if (this.showEpics()) {
      this.updateNavigation('NewStory{' + story.uniqueId + '}');
    } else {
      this.updateNavigation('NewTask{' + story.uniqueId + '}');
    }
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
    this.updateAllocations();
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

  protected moveStory(story: Story, oldEpic: Story, newEpicId: number) {
    let oldEpicId = oldEpic ? oldEpic.id : null;
    if (newEpicId !== oldEpicId) {
      if (oldEpic) {
        oldEpic.stories.splice(this.getIndex(oldEpic.stories, story.id), 1);
      } else {
        this.stories.splice(this.getIndex(this.stories, story.id), 1);
      }
      story.epic = this.id_map['S' + newEpicId];
      if (story.epic && story.epic.childrenLoaded) {
        story.epic.stories.push(story);
        story.epic_name = story.epic.name;
      } else if (newEpicId) {
        story.deleted = true; // no longer visible
      } else {
        this.stories.push(story);
        story.epic_name = null;
      }
      this.updateRows();
    }
  }

  finishedEditing(result: FinishedEditing): void {
    let work: Work = this.selection;
    if (work) {
      if (work.added) {
        work.added = false;
        this.addRow(work);
        this.checkRemoveRow(work);
        this.updateProjections();
        this.updateRows();
      } else if (work.isStory() && (<Story>work).split) {
        let originalStory = <Story>work;
        this.addRow(originalStory.split);
        originalStory.split = null;
        this.checkRemoveRow(originalStory);
        this.updateProjections();
        this.updateRows();
      } else {
        if (work.isStory() && this.showEpics()) {
          let story: Story = <Story>work;
          this.moveStory(story, story.epic, story.story_id);
        }
        this.checkRemoveRow(work);
        this.updateProjections();
        this.refreshView();
      }
    }
    switch (result) {
      case FinishedEditing.Next:
        this.updateNavigation(this.next() ? this.next().uniqueId : ParentWorkItemsComponent.noSelection);
        break;
      case FinishedEditing.Previous:
        this.updateNavigation(this.previous() ? this.previous().uniqueId : ParentWorkItemsComponent.noSelection);
        break;
      case FinishedEditing.AddAnother:
        this.applySelection(this.currentParams['selection']);
        break;
      case FinishedEditing.Save:
      case FinishedEditing.Cancel:
        this.updateNavigation(ParentWorkItemsComponent.noSelection);
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
    let parentStatus = rowItem.data.isStory() ?
      (!ParentWorkItemsComponent.instance.showEpics() || rowItem.data.canAddChildren() ? ' story-children' : ' story-no-children') : '';
    return (rowItem.data.isStory() ? 'story' : 'task') + parentStatus + ' id-' + rowItem.data.uniqueId;
  }

  getRowNodeId(rowItem): string {
    return rowItem.uniqueId;
  }

  protected getRowWork(jQueryObject: any): Work {
    let result: string = null;
    $.each(jQueryObject.attr('class').toString().split(' '), function (i: number, className: string) {
      if (className.indexOf('id-') === 0) {
        result = className.substring(3);
      }
    });
    return this.id_map[result];
  }

  dropRow(event, ui, target, copy: boolean): void {
    let movedRow: Work = this.getRowWork($(ui.draggable[0]));
    let targetRow: Work = this.getRowWork(target);
    if (movedRow.isStory()) {
      this.dropStory(<Story>movedRow, targetRow, copy);
    } else {
      this.dropTask(<Task>movedRow, targetRow, copy);
    }
  }

  private dropStory(story: Story, targetRow: Work, copy: boolean): void  {
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
    if (copy) {
      story = new Story(story);
    } else {
      this.stories.splice(this.stories.indexOf(story), 1);
    }
    if (targetStory) {
      this.stories.splice(this.stories.indexOf(targetStory), 0, story);
    } else {
      this.stories.push(story);
    }
    story.priority = this.determinePriority(this.stories, story);
    let method = copy ? this.storiesService.create : this.storiesService.update;
    method.call(this.storiesService, story).subscribe(
    (revisedStory) => {
      story.id = revisedStory.id;
      this.id_map[revisedStory.uniqueId] = story;
      this.updateRows();
      this.updateAllocations();
      this.updateProjections();
      this.storiesService.setRanks(this.stories);
      this.gridOptions.api.onSortChanged();
    }, (error) => this.processError.call(this, error));
  }

  private dropTask(task: Task, targetRow: Work, copy: boolean): void {
    let oldStory: Story = task.story;
    if (copy) {
      task = new Task(task);
    } else {
      oldStory.tasks.splice(oldStory.tasks.indexOf(task), 1);
    }
    let index: number = targetRow && targetRow.isStory() ? this.stories.indexOf(<Story> targetRow) : -1;
    let newStory: Story = targetRow ?
      (targetRow.isStory() ? (this.stories[index === 0 ? 0 : index - 1]) : (<Task> targetRow).story) :
      this.stories[this.stories.length - 1];
    if (oldStory.id !== newStory.id) {
      task.story = newStory;
      if (!copy) {
        task.previous_story_id = oldStory.id;
      }
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
    if (copy) {
      this.tasksService.create(task).subscribe(
          (revisedTask) => {
            task.id = revisedTask.id;
            this.id_map[revisedTask.uniqueId] = task;
            this.updateRows();
            this.updateAllocations();
          }, (error) => this.processError.call(this, error));
    } else {
      this.tasksService.update(task).subscribe(
        (revisedTask) => {
          task.previous_story_id = null;
          this.updateRows();
          this.updateAllocations();
        }, (error) => this.processError.call(this, error));
    }
    newStory.expanded = true;
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
    if (row.isStory() && (row.story_id === null || !this.showEpics())) {
      this.stories.push(<Story> row);
      this.storiesService.setRanks(this.stories);
      this.updateAllocations();
    } else {
      let story: Story = <Story>this.id_map['S' + row.story_id];
      if (story) {
        story.expanded = true;
        if (row.isStory()) {
          story.stories.push(<Story> row);
        } else {
          story.tasks.push(<Task> row);
        }
        this.updateAllocations();
      }
    }
  }

  checkRemoveRow(row: Work): void {
    let filtered = false;
    if ( row.deleted ) {
      filtered = true;
      if (row.isStory() && (<Story>row).stories.length > 0) {
        (<Story>row).stories.forEach((child: Story) => {
          child.epic = null;
          child.story_id = null;
          this.addRow(child);
        });
        this.updateRows();
      }
    } else if (row.isStory()) {
      let story: Story = <Story> row;
      if (!this.showEpics() && this.filters.release !== 'All') {
        if (this.filters.release === '') {
          filtered = filtered || story.release_id != null;
        } else if (this.filters.release === 'Current') {
          let currentReleaseId = this.filters.getCurrentReleaseId(this.filters.releases);
          filtered = filtered || (currentReleaseId !== null && story.release_id !== currentReleaseId);
        } else {
          filtered = filtered || String(story.release_id) !== this.filters.release;
        }
      }
      if (!this.showEpics() && this.filters.iteration !== 'All') {
        if (this.filters.iteration === '') {
          filtered = filtered || story.iteration_id != null;
        } else if (this.filters.iteration === 'Current') {
          let currentIterationId = this.filters.getCurrentIterationId(this.filters.iterations);
          filtered = filtered || (currentIterationId !== null && story.iteration_id !== currentIterationId);
        } else {
          filtered = filtered || String(story.iteration_id) !== this.filters.iteration;
        }
      }
      if (this.filters.team !== 'All') {
        if (this.filters.team === '') {
          filtered = filtered || story.team_id != null;
        } else if (this.filters.team === 'MyTeam') {
          filtered = filtered || story.team_id !== this.user.team_id;
        } else {
          filtered = filtered || String(story.team_id) !== this.filters.team;
        }
      }
      if (this.filters.individual !== 'All') {
        if (this.filters.individual === '') {
          filtered = filtered || story.individual_id != null;
        } else {
          filtered = filtered || String(story.individual_id) !== this.filters.individual;
        }
      }
    }
    if (this.filters.status !== 'All' && (!this.showEpics() || (<Story>row).epic == null)) {
      if (this.filters.status === 'NotDone') {
        filtered = filtered || (row.status_code === 3);
      } else {
        filtered = filtered || (row.status_code !== this.filters.status);
      }
    }
    if (filtered) {
      if (row.isStory()) {
        ((<Story>row).epic ? (<Story>row).epic : this).stories.splice(this.getIndex(this.stories, row.id), 1);
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
    this.updateProjections();
    this.updateAllocations();
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

  statusChanged(row: Work): void {
    if (row.isStory()) {
      this.storiesService.update(<Story> row).subscribe(
        (story: Story) => {
          this.updateGridForStatusChange(story);
          row.updateParentStatus();
          let parent: Story = (<Story>row).epic;
          while (parent) {
            this.updateGridForStatusChange(parent);
            parent = parent.epic;
          }
        },
        (err: any) => this.processError.call(this, err));
    } else {
      let changedTask: Task = <Task> row;
      this.tasksService.update(changedTask).subscribe(
        (task: Task) => {
          this.updateGridForStatusChange(task);
          row.updateParentStatus();
          let parent: Story = changedTask.story;
          while (parent) {
            this.updateGridForStatusChange(parent);
            parent = parent.epic;
          }
        },
        (err: any) => this.processError(err));
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
    let height: number = ParentWorkItemsComponent.instance.numPages > 1 ? 132 : 84;
    $('ag-grid-ng2').height($(window).height() - (height + (ParentWorkItemsComponent.instance.user &&
      ParentWorkItemsComponent.instance.user.is_premium ? PremiumReportsComponent.height : 0)));
  }

  setAttributes(storyAttributes: StoryAttribute[]): void {
    this.storyAttributes = storyAttributes;
    let newColumnDefs: any[] = [{
      headerName: '',
      width: 20,
      field: 'blank',
      headerComponentFramework: GroupHeaderComponent,
      cellRenderer: 'group',
      suppressMovable: true,
      suppressResize: true,
      suppressSorting: true
    }];
    this.filteredAttributes = [];
    storyAttributes.forEach((storyAttribute: StoryAttribute) => {
      if (storyAttribute.show &&
        (this.filters.release === 'All' || storyAttribute.name !== 'Release') &&
        (this.filters.iteration === 'All' || this.filters.iteration === '' || storyAttribute.name !== 'Iteration') &&
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
        if (storyAttribute.name === 'Rank') {
          columnDef.sort = 'asc';
          columnDef.comparator = function(valueA, valueB, nodeA, nodeB, isInverted) {
            return nodeA.priority - nodeB.priority;
          };
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
      this.expandWork(story, shouldExpand);
    });
    this.updateRows();
  }

  private expandWork(work: Work, shouldExpand: boolean): void {
    if (work.isStory) {
      let story: Story = <Story> work;
      story.expanded = shouldExpand;
      if (!story.hasLoaded()) {
        this.storiesService.getChildren(story, this.filters.getTeamId()).subscribe((children: Story[]) => {
          children.forEach((child: Story) => {
            this.id_map[child.uniqueId] = child;
          });
          this.updateRows();
        });
      }
    }
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

  private fetchEpics(): void {
    this.storiesService.getEpics(this.filters.status)
      .subscribe(
        (epics: Story[]) => this.epics = epics,
        (err: any) => this.processError(err));
  }

  private fetchProjects(): void {
    this.projectsService.getProjects()
      .subscribe(
        (projects: Project[]) => this.projects = projects,
        (err: any) => this.processError(err));
  }

  updateNavigation(selection?: String, split?: boolean): void {
    let params: Map<string, string> = new Map();
    this.filters.updateNavigationParams(params);
    if (selection) {
      this.selectionChanged = true;
      if (selection !== ParentWorkItemsComponent.noSelection) {
        params['selection'] = selection;
        if (split) {
          params['split'] = true;
        }
      }
    }
    this.router.navigate([this.getRoute(), params]);
  }

  private fetchPage(pageNumber: number): void {
    this.currentPage = pageNumber;
    this.fetchStories();
  }

  fetchStories(selection?: Work, ignoreErrors?: boolean, split?: boolean): void {
    this.waiting = true;
    this.storiesService.getStories(this.filters.queryString, this.currentPage)
      .subscribe(
        (stories: Story[]) => {
          this.setAttributes(this.storyAttributes);
          stories.forEach((story: Story) => {
            let prevStory: Story = this.id_map[story.uniqueId];
            this.id_map[story.uniqueId] = story;
            story.tasks.forEach((task: Task) => {
              this.id_map[task.uniqueId] = task;
            });
            if (prevStory && prevStory.expanded) {
              this.expandWork(story, true);
            }
          });
          this.stories = stories;
          this.updateProjections();
          this.updateExpandContractAll();
          if (selection) {
            this.applySelection(selection, split);
          }
          this.waiting = false;
          if (!this.menusLoaded) {
            this.menusLoaded = true;
            this.fetchMenus();
          } else {
            this.updateAllocations();
          }
        },
        (err: any) => {
          if (!ignoreErrors) {
            this.processError(err);
          }
        });
    this.storiesService.getStoriesNumPages(this.filters.queryString).subscribe(
      (numPages: number) => {
        this.numPages = numPages;
        this.setGridHeight();
      });
    this.fetchEpics();
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

  get numberOfStories(): number {
    return this.stories.length;
  }

  updateAllocations(): void {
    let velocityAllocation: Map<Team, number> = new Map<Team, number>();
    let storyAllocation: Map<Team, number> = new Map<Team, number>();
    let velocityById: Map<number, number> = new Map<number, number>();
    let storyById: Map<number, number> = new Map<number, number>();
    let totalVelocity = 0;
    let totalStory = 0;
    let stories = this.stories;
    if  (this.selectedWork.length > 0) {
      stories = [];
      this.selectedWork.forEach((work: Work) => {
        let story: Story = work.isStory ? <Story>work : (<Task>work).story;
        if (stories.indexOf(story) === -1) {
          stories.push(story);
        }
      });
    }
    stories.forEach((story: Story) => {
      let teamId: number = story.team_id ? story.team_id : 0;
      let currentVelocity: number = velocityById.get(teamId);
      let storySize = story.size ? story.size : 0;
      velocityById.set(teamId, currentVelocity ? currentVelocity + storySize : storySize);
      totalVelocity += storySize;
      let currentStory: number = storyById.get(teamId);
      let storyToDo = story.toDo ? story.toDo : 0;
      storyById.set(teamId, currentStory ? currentStory + storyToDo : storyToDo);
      totalStory += storyToDo;
    });
    if (this.filters.team === 'All') {
      this.filters.teams.forEach((team: Team) => {
        if (team.name !== 'My Team') {
          if (team.name === 'All Teams') {
            velocityAllocation.set(team, totalVelocity);
            storyAllocation.set(team, totalStory);
          } else {
            if (velocityById.get(team.id) != null) {
              velocityAllocation.set(team, velocityById.get(team.id));
            }
            if (storyById.get(team.id) != null) {
              storyAllocation.set(team, storyById.get(team.id));
            }
          }
        }
      });
    } else {
      let id: number = this.filters.team === 'MyTeam' ? this.user.team_id : parseInt(this.filters.team, 10);
      let self: ParentWorkItemsComponent = this;
      this.filters.teams.forEach((team: Team) => {
        if (self.filters.team === '' && team.name === 'No Team') {
          velocityAllocation.set(team, velocityById.get(0) ? velocityById.get(0) : 0);
          storyAllocation.set(team, storyById.get(0) ? storyById.get(0) : 0);
        } else if (team.id === id) {
          velocityAllocation.set(team, velocityById.get(id) ? velocityById.get(id) : 0);
          storyAllocation.set(team, storyById.get(id) ? storyById.get(id) : 0);
        }
      });
    }
    this.velocityAllocation = velocityAllocation;
    this.storyAllocation = storyAllocation;
  }

  private updateProjections(): void {
    if (this.user && this.user.is_premium && this.filters.iteration === '') {
      this.projectionsService.project(this.stories);
    }
  }
}
