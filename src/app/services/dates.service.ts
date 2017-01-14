import { Injectable } from '@angular/core';

@Injectable()
export class DatesService {
  parseDate(dateString: string): Date {
    if (dateString == null) {
      return null;
    }
    let parts: string[] = dateString.split('-');
    return new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
  }

  parseDateTime(dateString: string): Date {
    if (dateString == null) {
      return null;
    }
    let parts: string[] = dateString.split('-');
    return new Date(
      parseInt(parts[0], 10),
      parseInt(parts[1], 10) - 1,
      parseInt(parts[2], 10),
      parseInt(parts[2].substring(3, 5), 10),
      parseInt(parts[2].substring(6, 8), 10),
      parseInt(parts[2].substring(9, 11), 10),
      parseInt(parts[2].substring(12, 15), 10),
    );
  }

  getDateString(date: Date): string {
    if (date == null) {
      return null;
    }
    return this.getMonth(date) + '-' + date.getDate() + '-' + date.getFullYear();
  }

  getDateStringTwoDigit(date: Date): string {
    if (date == null) {
      return null;
    }
    return this.getTwoDigit(this.getMonth(date)) + '-' + this.getTwoDigit(date.getDate()) + '-' + date.getFullYear();
  }

  getDateStringYearFirst(date: Date): string {
    if (date == null) {
      return null;
    }
    return date.getFullYear() + '-' + this.getTwoDigit(this.getMonth(date)) + '-' + this.getTwoDigit(date.getDate());
  }

  getDateTimeString(date: Date): string {
    if (date == null) {
      return null;
    }
    let hour: number = date.getHours() > 12 ? date.getHours() - 12 : date.getHours();
    if (hour === 0) {
      hour = 12;
    }
    let minute: any = this.getTwoDigit(date.getMinutes());
    let ampm: string = date.getHours() > 11 ? 'pm' : 'am';
    return this.getMonth(date) + '-' + date.getDate() + '-' + date.getFullYear() + ' ' +
      hour + ':' + minute + ' ' + ampm;
  }

  private getMonth(date: Date): number {
    return date.getMonth() + 1;
  }

  private getTwoDigit(value: number): any {
    return value < 10 ? '0' + value : value;
  }
}
