import { Schedule } from './schedule';

export class Iteration extends Schedule {
  public project_id: number;
  public retrospective_results: string;
  public notable: string;

  static getNext(lastIteration: Iteration): Iteration {
    return new Iteration(Schedule.getNext(lastIteration, 'Iteration', 14));
  }

  constructor(values: any) {
    super(values);
    this.retrospective_results = values.retrospective_results;
    this.notable = values.notable;
  }
}
