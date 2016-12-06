export class Individual {
  public id: number;
  public login: string;
  public email: string;
  public first_name: string;
  public last_name: string;
  public activated_at: string;
  public enabled: boolean;
  public role: number;
  public last_login: string;
  public team_id: number;
  public phone_number; string;
  public notification_type: number;
  public company_id: number;
  public selected_project_id: number;
  public refresh_interval: number;
  public project_ids: number[];

  constructor(values: any) {
    this.id = values.id;
    this.login = values.login;
    this.email = values.email;
    this.first_name = values.first_name;
    this.last_name = values.last_name;
    this.activated_at = values.activated_at;
    this.enabled = values.enabled;
    this.role = values.role;
    this.last_login = values.last_login;
    this.team_id = values.team_id;
    this.phone_number = values.phone_number;
    this.notification_type = values.notification_type;
    this.company_id = values.company_id;
    this.selected_project_id = values.selected_project_id;
    this.refresh_interval = values.refresh_interval;
    this.project_ids = values.project_ids;
  }

  getName(): string {
    return this.first_name + (this.last_name ? (' ' + this.last_name) : '');
  }
}
