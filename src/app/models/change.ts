import { ReflectiveInjector } from '@angular/core';
import { DatesService } from '../services/dates.service';

export class Change {
  id: number;
  auditable_id: number;
  auditable_type: number;
  auditable_name: string;
  user_id: number;
  user_name: string;
  action: string;
  created_at: Date;
  audited_changes: any;

  constructor(values: any) {
    this.id = values.id;
    this.auditable_id = values.auditable_id;
    this.auditable_type = values.auditable_type;
    this.auditable_name = values.auditable_name;
    this.user_id = values.user_id;
    this.user_name = values.user_name;
    this.action = values.action;
    this.created_at = this.getDatesService().parseDateTime(values.created_at);
    if (values.audited_changes && this.action !== 'destroy') {
      let changes: string[] = [];
      for (let property in values.audited_changes) {
        if (values.audited_changes.hasOwnProperty(property) && values.audited_changes[property] != null) {
          let name_parts: string[] = property.split('_');
          for (let i = 0; i < name_parts.length; i++) {
            name_parts[i] = name_parts[i].charAt(0).toUpperCase() + name_parts[i].substring(1);
          }
          let name: string = name_parts.join(' ');
          let oldValue: string = values.audited_changes[property][0] == null ? null :
            ('' + values.audited_changes[property][0]).replace(/\r/g, '<br>');
          let newValue: string = ('' + values.audited_changes[property][1]).replace(/\r/g, '<br>');
          if (name === 'Status Code') {
            name = 'Status';
            oldValue = this.getStatus(oldValue);
            newValue = this.getStatus(newValue);
          }
          if (oldValue) {
            changes.push(name + ' has changed from \'' + oldValue + '\' to \'' + newValue + '\'');
          } else {
            changes.push(name + ' set to \'' + newValue + '\'');
          }
        }
      }
      if (changes.length > 0) {
        this.audited_changes = '<ul><li><div>' + changes.join('</div></li><li><div>') + '</div></li></ul>';
      }
    }
  }

  private getStatus(value: string): string {
    switch (value) {
      case '0':
        return 'Not Started';
      case '1':
        return 'In Progress';
      case '2':
        return 'Blocked';
      case '3':
        return 'Done';
    }
  }

  get created_string() {
    return this.getDatesService().getDateTimeString(this.created_at);
  }

  private getDatesService(): DatesService {
    return ReflectiveInjector.resolveAndCreate([DatesService]).get(DatesService);
  }
}
