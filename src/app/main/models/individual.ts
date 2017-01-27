import { ReflectiveInjector } from '@angular/core';
import { DatesService } from '../services/dates.service';

export class Individual {
  public id: number;
  public login: string;
  public email: string;
  public first_name: string;
  public last_name: string;
  public activated_at: string;
  public enabled: boolean;
  public role: number;
  public last_login: Date;
  public team_id: number;
  public team_name: string;
  public phone_number; string;
  public notification_type: number;
  public company_id: number;
  public selected_project_id: number;
  public refresh_interval: number;
  public project_ids: number[];
  public added: boolean = false;
  public password: string; // only present when changing
  public password_confirmation: string; // only present when changing
  public is_premium: boolean;

  constructor(values: any) {
    this.id = values.id;
    this.login = values.login;
    this.email = values.email;
    this.first_name = values.first_name;
    this.last_name = values.last_name;
    this.activated_at = values.activated_at;
    this.enabled = values.enabled;
    this.role = values.role;
    if (values.last_login) {
      if (values.last_login instanceof Date) {
        this.last_login = values.last_login;
      } else {
        this.last_login = this.getDatesService().parseDateTime(values.last_login);
      }
    }
    this.team_id = values.team_id;
    this.team_name = values.team_name;
    this.phone_number = values.phone_number;
    this.notification_type = values.notification_type;
    this.company_id = values.company_id;
    this.selected_project_id = values.selected_project_id;
    this.refresh_interval = values.refresh_interval;
    this.is_premium = values.is_premium;
    if (Array.isArray(values.project_ids)) {
      this.project_ids = values.project_ids;
    } else {
      let string_ids: string[] = values.project_ids ? values.project_ids.split(',') : [];
      this.project_ids = [];
      for (let i = 0; i < string_ids.length; i++) {
        this.project_ids[i] = parseInt(string_ids[i], 10);
      }
    }
  }

  get name(): string {
    return this.first_name + (this.last_name ? (' ' + this.last_name) : '');
  }

  get role_name(): string {
    switch (this.role) {
      case 0:
        return 'Admin';
      case 1:
        return 'Project Admin';
      case 2:
        return 'Project User';
      case 3:
        return 'Read Only User';
    }
  }

  get is_activated(): boolean {
    return this.activated_at != null;
  }

  get notify(): boolean {
    return this.notification_type !== 0;
  }

  set notify(notify: boolean) {
    this.notification_type = notify ? 1 : 0;
  }

  get refresh_interval_minutes(): number {
    return this.refresh_interval ? this.refresh_interval / (1000 * 60 * 5) : this.refresh_interval;
  }

  set refresh_interval_minutes(interval: number) {
    if (interval) {
      this.refresh_interval = interval * 1000 * 60 * 5;
    } else {
      this.refresh_interval = interval;
    }
  }

  get last_login_string() {
    return this.getDatesService().getDateTimeString(this.last_login);
  }

  canChangeBacklog(): boolean {
    return this.role <= 2;
  }

  canChangeRelease(): boolean {
    return this.role <= 1;
  }

  private getDatesService(): DatesService {
    return ReflectiveInjector.resolveAndCreate([DatesService]).get(DatesService);
  }
}
