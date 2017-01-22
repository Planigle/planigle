import { Schedule } from './schedule';

export class Release extends Schedule {
  static getNext(lastRelease: Release): Release {
    return new Release(Schedule.getNext(lastRelease, 'Release', 84));
  }

  constructor(values: any) {
    super(values);
  }
}
