export class Release {
  public id: number;
  public name: string;
  public start: Date;
  public finish: Date;
  public project_id: number;

  constructor(values: any) {
    this.id = values.id;
    this.name = values.name;
    if (values.start) {
      let startString: string[] = values.start.split('-');
      this.start = new Date(parseInt(startString[0], 10), parseInt(startString[1], 10), parseInt(startString[2], 10));
    }
    if (values.finish) {
      let finishString: string[] = values.finish.split('-');
      this.finish = new Date(parseInt(finishString[0], 10), parseInt(finishString[1], 10), parseInt(finishString[2], 10));
    }
    this.project_id = values.project_id;
  }

  isCurrent(): boolean {
    let now: Date = new Date();
    return now.getTime() > this.start.getTime() && now.getTime() < this.finish.getTime();
  }
}
