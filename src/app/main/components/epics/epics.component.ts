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
    let movedStory: Story = <Story>this.getRowWork($(ui.draggable[0]));
    let previousStory: Story = null;
    let followingStory: Story = <Story>this.getRowWork(target);
    let epic: Story = null;
    let stories: Story[] = this.stories;
    if (followingStory) {
      epic = followingStory.epic;
      if (epic) {
        stories = epic.stories;
        let index: number = this.getIndex(stories, followingStory.id);
        previousStory = index === 0 ? null : stories[index - 1];
      } else {
        let index: number = this.getIndex(stories, followingStory.id);
        if (index > 0) {
          previousStory = this.stories[index - 1];
          while (previousStory && previousStory.expanded && previousStory.isEpic()) {
            epic = previousStory;
            stories = previousStory.stories;
            previousStory = stories.length > 0 ? stories[stories.length - 1] : null;
            followingStory = null;
          }
        }
      }
    } else {
      previousStory = this.stories[this.stories.length - 1];
      while (previousStory && previousStory.expanded && previousStory.isEpic()) {
        epic = previousStory;
        stories = previousStory.stories;
        previousStory = stories.length > 0 ? previousStory.stories[stories.length - 1] : null;
        followingStory = null;
      }
    }
    let index: number = followingStory ? this.getIndex(stories, followingStory.id) : stories.length;
    let previousPriority: number = previousStory ? previousStory.priority : followingStory.priority - 10;
    let followingPriority: number = followingStory ? followingStory.priority : previousStory.priority + 10;
    movedStory.priority = (previousPriority + followingPriority) / 2;
    if (epic !== movedStory.epic) {
      let epicId: number = epic ? epic.id : null;
      this.moveStory(movedStory, movedStory.epic, epicId);
      movedStory.story_id = epicId;
    }
    let oldIndex: number = this.getIndex(stories, movedStory.id);
    stories.splice(oldIndex, 1);
    stories.splice(index, 0, <Story>movedStory);
    this.storiesService.update(movedStory).subscribe((revisedStory: Story) => {
      movedStory.id = revisedStory.id;
      this.id_map[revisedStory.uniqueId] = movedStory;
      this.checkRemoveRow(movedStory);
      this.updateParentStatus(movedStory);
      this.storiesService.setRanks(this.stories);
      this.updateRows();
      this.updateAllocations();
      this.updateProjections();
      this.gridOptions.api.onSortChanged();
    });
  }
}
