export abstract class Organization {
  public id: number;
  public name: string;
  public added: boolean;
  public expanded: boolean;

  constructor(values: any) {
    this.id = values.id;
    this.name = values.name;
  }

  abstract get uniqueId(): string;

  isCompany(): boolean {
    return false;
  }

  isProject(): boolean {
    return false;
  }

  isTeam(): boolean {
    return false;
  }
}
