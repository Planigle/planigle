export class Schedule {
  public id: number;
  public name: string;
  public start: Date;
  public finish: Date;
  public project_id: number;
  public added: boolean;
  
  constructor(values: any) {
    this.id = values.id;
    this.name = values.name;
    if (values.start) {
      if(values.start instanceof Date) {
        this.start = values.start;
      } else {
        let startString: string[] = values.start.split('-');
        this.start = new Date(parseInt(startString[0], 10), parseInt(startString[1], 10)-1, parseInt(startString[2], 10));
      }
    }
    if (values.finish) {
      if(values.finish instanceof Date) {
        this.finish = values.finish;
      } else {
        let finishString: string[] = values.finish.split('-');
        this.finish = new Date(parseInt(finishString[0], 10), parseInt(finishString[1], 10)-1, parseInt(finishString[2], 10));
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
    return (date.getMonth()+1) + '-' + date.getDate() + '-' + date.getFullYear()
  }
  
  private formatDateTwoDigit(date: Date): string {
    let month = date.getMonth()+1;
    let day = date.getDate();
    return (month < 10 ? '0' : '') + month + '-' + (day < 10 ? '0' : '') + day + '-' + date.getFullYear()
  }
    
  private formatDateYearFirst(date: Date): string {
    let month = date.getMonth()+1;
    let day = date.getDate();
    return date.getFullYear() + '-' + (month < 10 ? '0' : '') + month + '-' + (day < 10 ? '0' : '') + day
  }
  
  static getNext(lastSchedule: Schedule, defaultName: string, defaultIncrement: number): any {
    let name: String = defaultName + ' 1';
    let start: Date = new Date();
    let finish: Date = new Date();
    if(lastSchedule) {
      let splits: string[] = lastSchedule.name.split(" ");
      let last: string = splits[splits.length - 1];
      if(String(parseInt(last)) === last) { // numeric
        splits[splits.length - 1] = String(parseInt(last) + 1);
        name = splits.join(' ');
      } else {
        name = '';
      }
      start = lastSchedule.finish
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
}
