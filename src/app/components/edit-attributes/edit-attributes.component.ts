import { Component, OnInit } from '@angular/core';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { StoryAttributesService } from '../../services/story-attributes.service';
import { ErrorService } from '../../services/error.service';
import { StoryAttribute } from '../../models/story-attribute';
import { StoryAttributeValue } from '../../models/story-attribute-value';
import { Release } from '../../models/release';

@Component({
  selector: 'app-edit-attributes',
  templateUrl: './edit-attributes.component.html',
  styleUrls: ['./edit-attributes.component.css'],
  providers: [StoryAttributesService, ErrorService]
})
export class EditAttributesComponent {
  originalAttributes: StoryAttribute[] = [];
  customStoryAttributes: StoryAttribute[] = [];
  selectedAttribute: StoryAttribute;
  selectedValue: StoryAttributeValue;
  releases: Release[] = [];
  selectedRelease: Release;
  hasChanges: boolean = false;

  constructor(
    private activeModal: NgbActiveModal,
    private storyAttributesService: StoryAttributesService,
    private errorService: ErrorService
  ) { }
  
  setCustomStoryAttributes(storyAttributes: StoryAttribute[]): void {
    this.hasChanges = false;
    this.originalAttributes = storyAttributes;
    storyAttributes.forEach((storyAttribute: StoryAttribute) => {
      this.customStoryAttributes.push(new StoryAttribute(storyAttribute));
    });
  }
  
  setReleases(releases: Release[]): void {
    this.releases = releases.slice(0);
    let none = new Release({
      name: 'No Release'
    });
    this.releases.push(none);
    this.selectedRelease = none;
  }
  
  selectAttribute(attribute: StoryAttribute): void {
    this.selectedAttribute = attribute;
    this.selectedValue = null;
  }
  
  addAttribute(): void {
    let attribute: StoryAttribute = this.newAttribute();
    this.customStoryAttributes.push(attribute);
    this.selectedAttribute = attribute;
  }
  
  private newAttribute(): StoryAttribute {
    return new StoryAttribute({
      name: 'New Attribute',
      value_type: 0,
      is_custom: true,
      show: false,
      width: 100
    });
  }
  
  deleteAttribute(attribute: StoryAttribute): void {
    this.customStoryAttributes.splice(this.customStoryAttributes.indexOf(attribute), 1);
  }
  
  isSelected(attribute: StoryAttribute): boolean {
    return this.selectedAttribute == attribute;
  }
  
  updateAttributeType(attribute: StoryAttribute): void {
    if(attribute.hasList() && attribute.storyAttributeValues.length == 0) {
      this.addValue();
    }
  }
  
  selectValue(value: StoryAttributeValue): void {
    this.selectedValue = value;
  }
      
  addValue(): void {
    let value: StoryAttributeValue = this.newValue();
    this.selectedAttribute.storyAttributeValues.push(value);
    this.selectedValue = value;
  }
  
  private newValue(): StoryAttributeValue {
    let value: StoryAttributeValue = new StoryAttributeValue({
      story_attribute_id: this.selectedAttribute.id,
      value: 'New Value'
    });
    if (this.selectedAttribute.value_type == 4 && this.selectedRelease != null && String(this.selectedRelease.id) != 'null') {
      value.release_id = this.selectedRelease.id;
    }
    return value
  }
    
  deleteValue(value: StoryAttributeValue): void {
    this.selectedAttribute.storyAttributeValues.splice(this.selectedAttribute.storyAttributeValues.indexOf(value), 1);
  }
  
  isSelectedValue(value: StoryAttributeValue): boolean {
    return this.selectedValue == value;
  }
  
  ok(): void {
    this.processChanges(this.determineChanges());
  }
  
  private processChanges(changes: any[]): void {
    if (changes.length > 0) {
      this.hasChanges = true;
      this.processChange(changes);
    } else {
      this.activeModal.close('OK');
    }
  }
  
  private processChange(changes: any[]): void {
    let change: any = changes[0];
    changes = changes.slice(1);
    change.method.call(this.storyAttributesService, change.parameter)
    .subscribe(
      (attribute: StoryAttribute) => this.processChanges(changes),
      (err: any) => this.errorService.showError(err));
  }
  
  private determineChanges(): any[] {
    let self: EditAttributesComponent = this;
    let changes: any[] = [];
    this.originalAttributes.forEach((attribute: StoryAttribute) => {
      if (!self.find(self.customStoryAttributes, attribute)) {
        changes.push({
          method: self.storyAttributesService.delete,
          parameter: attribute
        });
      }
    });
    this.customStoryAttributes.forEach((attribute: StoryAttribute) => {
      let original: StoryAttribute = self.find(self.originalAttributes, attribute);
      if (!original) {
        changes.push({
          method: self.storyAttributesService.create,
          parameter: attribute
        });
      } else {
        if(original.name !== attribute.name || original.value_type !== attribute.value_type ||
          original.values() !== attribute.values()) {
          changes.push({
            method: self.storyAttributesService.update,
            parameter: attribute
          });
        }
      }
    });
    return changes;
  }
  
  private find(attributes: any[], attribute: any): any {
    let found: any = null;
    attributes.forEach((candidate: any) => {
      if(candidate.id === attribute.id) {
        found = candidate;
      }
    });
    return found;
  }

  cancel(): void {
    this.activeModal.close('Cancel');
  }
  
  handleAttributeKeyStroke(event): void {
    this.handleKeyStroke(event, this.customStoryAttributes, this.selectedAttribute, this.selectAttribute, this.addAttribute, this.newAttribute, 'name');
  }
    
  handleValueKeyStroke(event): void {
    this.handleKeyStroke(event, this.selectedAttribute.storyAttributeValues, this.selectedValue, this.selectValue, this.addValue, this.newValue, 'value');
  }
  
  private handleKeyStroke(event, values: any[], selection, select, add, create, property): void {
    let key: string = event.key;
    let index: number = values === null ? null : values.indexOf(selection);
    if (key === 'ArrowDown' || key === 'Enter') {
      if (index !== -1 && index < values.length - 1) {
        select.call(this, values[index + 1]);
      } else {
        add.call(this);
      }
      event.preventDefault();
    } else if (key === 'ArrowUp') { // up arrow
      if (index !== -1 && index > 0) {
        select.call(this, values[index - 1]);
      }
      event.preventDefault();
    } else if((event.ctrlKey || event.metaKey) && key === 'v') {
      setTimeout(() => {
        let rows: string[] = selection[property].split('\n');
        if(rows.length > 1) {
          let objects: any[] = values.slice(0);
          objects.splice(0,objects.indexOf(selection));
          if (rows.length > objects.length) {
            let length: number = objects.length;
            for(let i=0; i<rows.length - length; i++) {
              let object: any = create.call(this);
              values.push(object);
              objects.push(object);
            }
          }
          for(let i=0; i<rows.length; i++) {
            objects[i][property] = rows[i];
          }
        }
      }, 500);
    }
  }
}
