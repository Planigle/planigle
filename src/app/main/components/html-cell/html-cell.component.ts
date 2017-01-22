import { Component } from '@angular/core';
import { AgRendererComponent } from 'ag-grid-ng2/main';
declare var $: any;

@Component({
  selector: 'app-html-cell',
  templateUrl: './html-cell.component.html',
  styleUrls: ['./html-cell.component.css']
})
export class HtmlCellComponent implements AgRendererComponent {
  value: string;

  agInit(params: any): void {
    this.value = params.value;
  }
}
