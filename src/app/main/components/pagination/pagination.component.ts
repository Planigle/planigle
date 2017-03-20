import { Component, Input, Output, EventEmitter, OnChanges } from '@angular/core';

@Component({
  selector: 'app-pagination',
  templateUrl: './pagination.component.html',
  styleUrls: ['./pagination.component.css']
})
export class PaginationComponent implements OnChanges {
  @Input() currentPage: number = 1;
  @Input() numPages: number = 1;
  @Output() changePage: EventEmitter<any> = new EventEmitter();
  public pageNumbers: number[] = [1];

  ngOnChanges(changes): void {
    if (changes.numPages || changes.currentPage) {
      let pageNumbers = [];
      for (let i = 1; i <= this.numPages; i++) {
        if (i === 1 || i === this.numPages || (i >= this.currentPage - 3 && i <= this.currentPage + 3)) {
          pageNumbers.push(i);
        }
      }
      this.pageNumbers = pageNumbers;
    }
  }

  fetchPage(pageNumber: number): void {
    this.currentPage = pageNumber;
    this.changePage.emit({value: pageNumber});
  }
}
