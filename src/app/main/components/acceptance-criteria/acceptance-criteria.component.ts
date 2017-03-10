import { Component, OnChanges, Input, AfterViewInit } from '@angular/core';
import { AcceptanceCriterium } from '../../models/acceptance-criterium';
import { Story } from '../../models/story';
import { Individual } from '../../models/individual';
declare var $: any;

@Component({
  selector: 'app-acceptance-criteria',
  templateUrl: './acceptance-criteria.component.html',
  styleUrls: ['./acceptance-criteria.component.css']
})
export class AcceptanceCriteriaComponent implements OnChanges, AfterViewInit {
  public static instructions: String = '<Enter criteria here; Press Enter or down arrow to add additional>';
  @Input() model: Story;
  @Input() me: Individual;
  criteriumToEdit: AcceptanceCriterium;
  addedId: number = -1;

  constructor() { }

  ngOnChanges(changes): void {
    if (changes.model) {
      this.ensureAtLeastOneCriterium();
    }
  }

  ngAfterViewInit(): void {
    if (this.me.canChangeBacklog()) {
      let self: AcceptanceCriteriaComponent = this;
      $('.grid').selectable({
        filter: '.content',
        cancel: '.status, .delete, textarea',
        start: function(event, ui) {
          self.stopEditingCriterium();
        },
        stop: function(event, ui) {
          let selection = self.selection();
          if (selection.length === 1) {
            let criterium: AcceptanceCriterium = self.getCriterium.call(self, selection);
            self.unselectCriteria();
            self.editCriterium(criterium);
          } else {
            self.pasteArea().focus();
          }
        }
      });
      $('body').keydown(function(event) {
        self.cutPaste.call(self, event);
      });
    }
  }

  unselectCriteria(): void {
    $('.ui-selected').removeClass('ui-selected');
  }

  private getCriterium(selection: any): AcceptanceCriterium {
    let response: AcceptanceCriterium = null;
    let id: number = parseInt(selection.attr('criterium'), 10);
    this.model.acceptance_criteria.forEach((criterium: AcceptanceCriterium) => {
      if (criterium.id === id) {
        response = criterium;
      }
    });
    return response;
  }

  editCriterium(criterium): void {
    this.criteriumToEdit = null;
    setTimeout(() => {
      this.criteriumToEdit = criterium;
    }, 100);
  }

  stopEditingCriterium(): void {
    this.criteriumToEdit = null;
  }

  deleteCriterium(criterium): void {
    this.model.acceptance_criteria.splice(this.model.acceptance_criteria.indexOf(criterium), 1);
    this.ensureAtLeastOneCriterium();
  }

  cutPaste(event): void {
    let self: AcceptanceCriteriaComponent = this;
    let selection: any = this.selection();
    if ($(':focus').attr('id') !== 'pasteArea' || selection.length <= 1 || (!event.ctrlKey && !event.metaKey)) {
      // focus is elsewhere or it isn't CTRL + key
      return;
    }
    let key: string = event.key.toLowerCase();
    if (key === 'c' || key === 'x') {
      let buffer = '';
      selection.each(function() {
        let criterium: AcceptanceCriterium = self.getCriterium.call(self, $(this));
        if (key === 'x') {
          self.model.acceptance_criteria.splice(self.model.acceptance_criteria.indexOf(criterium), 1);
        }
        if (buffer !== '') {
          buffer += '\n';
        }
        buffer += criterium.description;
      });
      this.pasteArea().val(buffer).select();
    } else if (key === 'v') {
      this.pasteArea().select();
      setTimeout(() => {
        let rows: string[] = this.pasteArea().val().split('\n');
        let acceptanceCriteria: AcceptanceCriterium[] = [];
        selection.each(function() {
          acceptanceCriteria.push(self.getCriterium($(this)));
        });
        if (rows.length > acceptanceCriteria.length) {
          let index: number = this.model.acceptance_criteria.indexOf(acceptanceCriteria[0]) + acceptanceCriteria.length;
          let length: number = acceptanceCriteria.length;
          for (let i = 0; i < rows.length - length; i++) {
            let acceptanceCriterium: AcceptanceCriterium = this.createNewAcceptanceCriterium();
            this.model.acceptance_criteria.splice(index + i, 0, acceptanceCriterium);
            acceptanceCriteria.push(acceptanceCriterium);
            setTimeout(() => {
              $('.content[criterium="' + acceptanceCriterium.id + '"]').addClass('ui-selected');
            }, 0);
          }
        } else if (acceptanceCriteria.length > rows.length) {
          this.model.acceptance_criteria.splice(
            this.model.acceptance_criteria.indexOf(acceptanceCriteria[rows.length - 1]) + 1,
            acceptanceCriteria.length - rows.length);
        }
        for (let i = 0; i < rows.length; i++) {
          acceptanceCriteria[i].description = rows[i];
        }
      }, 500);
    }
  }

  private pasteArea(): any {
    return $('#pasteArea');
  }

  handleKeyStroke(event): void {
    let key: string = event.key;
    let index: number = this.criteriumToEdit === null ? null : this.model.acceptance_criteria.indexOf(this.criteriumToEdit);
    if (key === 'ArrowDown' || key === 'Enter') {
      if (index !== -1 && index < this.model.acceptance_criteria.length - 1) {
        this.editCriterium(this.model.acceptance_criteria[index + 1]);
      } else {
        this.addAcceptanceCriterium('');
        this.editCriterium(this.model.acceptance_criteria[this.model.acceptance_criteria.length - 1]);
      }
      event.preventDefault();
    } else if (key === 'ArrowUp') { // up arrow
      if (index !== -1 && index > 0) {
        this.editCriterium(this.model.acceptance_criteria[index - 1]);
      }
      event.preventDefault();
    } else if ((event.ctrlKey || event.metaKey) && key === 'v') {
      setTimeout(() => {
        let rows: string[] = this.criteriumToEdit.description.split('\n');
        if (rows.length > 1) {
          let objects: any[] = this.model.acceptance_criteria.slice(0);
          objects.splice(0, objects.indexOf(this.criteriumToEdit));
          if (rows.length > objects.length) {
            let length: number = objects.length;
            for (let i = 0; i < rows.length - length; i++) {
              let object: any = this.createNewAcceptanceCriterium();
              this.model.acceptance_criteria.push(object);
              objects.push(object);
            }
          }
          for (let i = 0; i < rows.length; i++) {
            objects[i].description = rows[i];
          }
        }
      }, 500);
    }
  }

  private selection(): any {
    return $('.grid .ui-selected.content');
  }

  private ensureAtLeastOneCriterium(): void {
    if (this.model.acceptance_criteria.length === 0) {
      this.addAcceptanceCriterium(AcceptanceCriteriaComponent.instructions);
    }
  }

  private addAcceptanceCriterium(description): void {
    this.model.acceptance_criteria.push(this.createNewAcceptanceCriterium(description));
  }

  private createNewAcceptanceCriterium(description?: string): AcceptanceCriterium {
    let acceptanceCriterium: AcceptanceCriterium = new AcceptanceCriterium({
      id: this.addedId,
      description: description,
      status_code: 0,
      story_id: this.model.id
    });
    this.addedId -= 1;
    return acceptanceCriterium;
  }
}
