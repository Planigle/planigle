import { Component } from '@angular/core';
import { AgRendererComponent } from 'ag-grid-ng2/main';

@Component({
  selector: 'app-button-bar',
  templateUrl: './button-bar.component.html',
  styleUrls: ['./button-bar.component.css']
})
export class ButtonBarComponent implements AgRendererComponent {
  private model: any;
  private gridHolder: any;

  constructor() { }

  agInit(params: any): void {
    this.model = params.data;
    this.gridHolder = params.context.gridHolder;
  }

  edit() {
    this.gridHolder.selection = this.model;
  }
}
