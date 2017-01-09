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
      if(values.last_login instanceof Date) {
        this.last_login = values.last_login;
      } else {
        let lastLoginString: string[] = values.last_login.split('-');
        this.last_login = new Date(
          parseInt(lastLoginString[0], 10),
          parseInt(lastLoginString[1], 10)-1,
          parseInt(lastLoginString[2], 10),
          parseInt(lastLoginString[2].substring(3,5)),
          parseInt(lastLoginString[2].substring(6,8)),
          parseInt(lastLoginString[2].substring(9,11)),
          parseInt(lastLoginString[2].substring(12,15)),
        );
      }
    }
    this.team_id = values.team_id;
    this.team_name = values.team_name;
    this.phone_number = values.phone_number;
    this.notification_type = values.notification_type;
    this.company_id = values.company_id;
    this.selected_project_id = values.selected_project_id;
    this.refresh_interval = values.refresh_interval;
    this.project_ids = values.project_ids;
  }

  get name(): string {
    return this.first_name + (this.last_name ? (' ' + this.last_name) : '');
  }
  
  get role_name(): string {
    switch(this.role) {
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
    return this.notification_type !=- 0;
  }
  
  set notify(notify: boolean) {
    this.notification_type = notify ? 1 : 0;
  }
  
  get refresh_interval_minutes(): number {
    return this.refresh_interval ? this.refresh_interval / (1000 * 60 * 5) : this.refresh_interval;
  }
  
  set refresh_interval_minutes(interval: number) {
    if(interval) {
      this.refresh_interval = interval * 1000 * 60 * 5;
    } else {
      this.refresh_interval = interval;
    }
  }
  
  get last_login_string() {
    if(this.last_login) {
      let hour: number = this.last_login.getHours() > 12 ? this.last_login.getHours() - 12 : this.last_login.getHours();
      if(hour == 0) {
        hour = 12;
      }
      let minute: any = this.last_login.getMinutes() < 10 ? '0' + this.last_login.getMinutes() : this.last_login.getMinutes();
      let ampm: string = this.last_login.getHours() > 11 ? 'pm' : 'am';
      return (this.last_login.getMonth()+1) + '-' + this.last_login.getDate() + '-' + this.last_login.getFullYear() + ' ' +
        hour + ':' + minute + ' ' + ampm;
    } else {
      return null;
    }
  }
  
  canChangeBacklog(): boolean {
    return this.role <= 2;
  }

  canChangeRelease(): boolean {
    return this.role <= 1;
  }
}
