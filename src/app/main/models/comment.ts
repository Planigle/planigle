import { ReflectiveInjector } from '@angular/core';
import { DatesService } from '../services/dates.service';

export class Comment {
  public id: number;
  public story_id: number;
  public individual_id: number;
  public individual_name: string;
  public message: string;
  public original_message: string;
  public created_at: Date;
  public editing: boolean;

  constructor(values: any) {
    this.id = values.id;
    this.story_id = values.story_id;
    this.individual_id = values.individual_id;
    this.individual_name = values.individual_name;
    this.message = values.message;
    this.original_message = values.message;
    this.editing = values.editing !== undefined && values.editing;
    if (values.created_at) {
      if (values.created_at instanceof Date) {
        this.created_at = values.created_at;
      } else {
        this.created_at = this.getDatesService().parseDateTime(values.created_at);
      }
    }
  }

  get startString(): string {
    return this.created_at == null ? 'now' : ('at ' + this.formatDate(this.created_at));
  }

  private formatDate(date: Date): string {
    return this.getDatesService().getDateTimeString(date);
  }

  private getDatesService(): DatesService {
    return ReflectiveInjector.resolveAndCreate([DatesService]).get(DatesService);
  }

  isNew(): boolean {
    return (this.id == null || this.id === undefined) && this.message.trim() !== '';
  }

  isDeleted(): boolean {
    return (this.id != null && this.id !== undefined) && this.message.trim() === '';
  }

  hasChanged(): boolean {
    return this.message.trim() !== this.original_message.trim();
  }
}
