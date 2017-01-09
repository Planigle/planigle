import { Component } from '@angular/core';
import { AgRendererComponent } from 'ag-grid-ng2/main';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { TeamsComponent } from '../teams/teams.component';
import { ConfirmationDialogComponent } from '../confirmation-dialog/confirmation-dialog.component';
import { Organization } from '../../models/organization';
import { Company } from '../../models/company';
import { Project } from '../../models/project';
import { Team } from '../../models/team';

@Component({
  selector: 'app-team-actions',
  templateUrl: './team-actions.component.html',
  styleUrls: ['./team-actions.component.css']
})
export class TeamActionsComponent implements AgRendererComponent {
  model: Organization;
  grid: TeamsComponent;
  
  constructor(
      private modalService: NgbModal,
  ) { }

  agInit(params: any): void {
    this.model = params.data;
    this.grid = params.context.gridHolder;
  }
  
  addProject(): void {
    this.grid.addProject(<Company> this.model);
  }
  
  addTeam(): void {
    this.grid.addTeam(<Project> this.model);
  }
  
  edit(): void {
    this.grid.editOrganization(this.model);
  }
  
  deleteItem(): void {
    let self: TeamActionsComponent = this;
    const modalRef: NgbModalRef = this.modalService.open(ConfirmationDialogComponent);
    let component: ConfirmationDialogComponent = modalRef.componentInstance;
    component.confirmDelete('Iteration', this.model.name);
    modalRef.result.then(
      (result: any) => {
        if (component.model.confirmed) {
          if(self.model.isTeam()) {
            self.grid.deleteTeam(<Team> self.model);
          } else {
            self.grid.deleteProject(<Project> self.model);
          }
        }
      }
    );
  }
}
