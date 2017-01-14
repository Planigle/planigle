import { ReflectiveInjector } from '@angular/core';
import { DatesService } from '../services/dates.service';

export class Schedule {
  public id: number;
  public name: string;
  public start: Date;
  public finish: Date;
  public project_id: number;
  public added: boolean;

  static getNext(lastSchedule: Schedule, defaultName: string, defaultIncrement: number): any {
    let name: String = defaultName + ' 1';
    let start: Date = new Date();
    let finish: Date = new Date();
    if (lastSchedule) {
      let splits: string[] = lastSchedule.name.split(' ');
      let last: string = splits[splits.length - 1];
      if (String(parseInt(last, 10)) === last) { // numeric
        splits[splits.length - 1] = String(parseInt(last, 10) + 1);
        name = splits.join(' ');
      } else {
        name = '';
      }
      start = lastSchedule.finish;
      finish = new Date(start.getTime() + (lastSchedule.finish.getTime() - lastSchedule.start.getTime()));
    } else {
      finish.setDate(finish.getDate() + defaultIncrement);
    }
    return {
      name: name,
      start: start,
      finish: finish
    };
  }

  constructor(values: any) {
    this.id = values.id;
    this.name = values.name;
    if (values.start) {
      if (values.start instanceof Date) {
        this.start = values.start;
      } else {
        this.start = this.getDatesService().parseDate(values.start);
      }
    }
    if (values.finish) {
      if (values.finish instanceof Date) {
        this.finish = values.finish;
      } else {
        this.finish = this.getDatesService().parseDate(values.finish);
      }
    }
    this.project_id = values.project_id;
  }

  isCurrent(): boolean {
    let now: Date = new Date();
    return now.getTime() > this.start.getTime() && now.getTime() < this.finish.getTime();
  }

  get startString(): string {
    return this.formatDate(this.start);
  }

  get startStringTwoDigit(): string {
    return this.formatDateTwoDigit(this.start);
  }

  get startStringYearFirst(): string {
    return this.formatDateYearFirst(this.start);
  }

  get finishString(): string {
    return this.formatDate(this.finish);
  }

  get finishStringTwoDigit(): string {
    return this.formatDateTwoDigit(this.finish);
  }

  get finishStringYearFirst(): string {
    return this.formatDateYearFirst(this.finish);
  }

  private formatDate(date: Date): string {
    return this.getDatesService().getDateString(date);
  }

  private formatDateTwoDigit(date: Date): string {
    return this.getDatesService().getDateStringTwoDigit(date);
  }

  private formatDateYearFirst(date: Date): string {
    return this.getDatesService().getDateStringYearFirst(date);
  }

  private getDatesService(): DatesService {
    return ReflectiveInjector.resolveAndCreate([DatesService]).get(DatesService);
  }
}
