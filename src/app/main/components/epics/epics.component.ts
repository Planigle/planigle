import { Component, AfterViewInit, OnDestroy } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { ParentWorkItemsComponent } from '../parent-work-items.component';
import { SessionsService } from '../../services/sessions.service';
import { StoryAttributesService } from '../../services/story-attributes.service';
import { ProjectionsService } from '../../../premium/services/projections.service';
import { ErrorService } from '../../services/error.service';
import { ProjectsService } from '../../services/projects.service';
import { StoriesService } from '../../services/stories.service';
import { TasksService } from '../../services/tasks.service';
import { DragDropService } from '../../services/drag-drop.service';
import { Work } from '../../models/work';
import { Story } from '../../models/story';
declare var $: any;

@Component({
  selector: 'app-epics',
  templateUrl: './epics.component.html',
  styleUrls: ['./epics.component.css'],
  providers: [StoriesService, TasksService, StoryAttributesService, ProjectsService, ProjectionsService, DragDropService]
})
export class EpicsComponent extends ParentWorkItemsComponent implements AfterViewInit, OnDestroy {
  constructor(
    router: Router,
    route: ActivatedRoute,
    modalService: NgbModal,
    sessionsService: SessionsService,
    storyAttributesService: StoryAttributesService,
    projectsService: ProjectsService,
    storiesService: StoriesService,
    tasksService: TasksService,
    projectionsService: ProjectionsService,
    dragDropService: DragDropService,
    errorService: ErrorService
  ) {
    super(
      router, route, modalService, sessionsService, storyAttributesService, projectsService,
      storiesService, tasksService, projectionsService, dragDropService, errorService);
  }

  getRoute(): string {
    return 'epics';
  }

  showEpics(): boolean {
    return true;
  }

  dropRow(event, ui, target): void {
    let movedRow: Work = this.getRowWork($(ui.draggable[0]));
    let targetRow: Work = this.getRowWork(target);
    let children: Story[] = (<Story>targetRow).epic ? (<Story>targetRow).epic.stories : this.stories;
    let index: number = this.getIndex(children, targetRow.id);
    let prev: number = index === 0 ? targetRow.priority - 10 : children[index - 1].priority;
    movedRow.priority = (prev + targetRow.priority) / 2;
    if (targetRow.story_id !== movedRow.story_id) {
      this.moveStory(<Story>movedRow, (<Story>movedRow).epic, targetRow.story_id);
      movedRow.story_id = targetRow.story_id;
    }
    let oldIndex: number = this.getIndex(children, movedRow.id);
    children.splice(oldIndex, 1);
    children.splice(index, 0, <Story>movedRow);
    this.updateRows();
    this.checkRemoveRow(movedRow);
    this.storiesService.update(movedRow).subscribe((story: Story) => {
      // all done
    });
  }
}
