import { Schedule } from './schedule';

export class Release extends Schedule {
  constructor(values: any) {
    super(values);
  }
  
  static getNext(lastRelease: Release): Release {
    return new Release(Schedule.getNext(lastRelease, 'Release', 84));
  }
}
