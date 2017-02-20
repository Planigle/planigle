import { Component } from '@angular/core';
import { IHeaderAngularComp } from 'ag-grid-ng2/main';

@Component({
  selector: 'app-group-header',
  templateUrl: './group-header.component.html',
  styleUrls: ['./group-header.component.css']
})
export class GroupHeaderComponent implements IHeaderAngularComp {
    agInit(params: any): void {
    }
}
