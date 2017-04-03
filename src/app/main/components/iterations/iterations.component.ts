import { Component, OnInit, AfterViewInit, OnDestroy } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { GridOptions } from 'ag-grid/main';
import { ConfirmationDialogComponent } from '../confirmation-dialog/confirmation-dialog.component';
import { IterationsService } from '../../services/iterations.service';
import { SessionsService } from '../../services/sessions.service';
import { Iteration } from '../../models/iteration';
import { Individual } from '../../models/individual';
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-iterations',
  templateUrl: './iterations.component.html',
  styleUrls: ['./iterations.component.css'],
  providers: [IterationsService]
})
export class IterationsComponent implements OnInit, AfterViewInit, OnDestroy {
  public gridOptions: GridOptions = <GridOptions>{};
  public columnDefs: any[] = [];
  public iterations: Iteration[] = null;
  public selection: Iteration;
  public user: Individual;
  public editing: boolean = false;
  private id_map: Map<string, Iteration> = new Map();

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private modalService: NgbModal,
    private sessionsService: SessionsService,
    private iterationsService: IterationsService
  ) {}

  ngOnInit(): void {
    this.user = new Individual(this.sessionsService.getCurrentUser());
  }

  ngAfterViewInit(): void {
    this.setGridHeight();
    $(window).resize(this.setGridHeight);
    this.route.params.subscribe((params: Map<string, string>) => this.applyNavigation(params));
    this.columnDefs = [{
      headerName: 'Name',
      width: 300,
      field: 'name'
    }, {
      headerName: 'Start',
      width: 200,
      field: 'startString'
    }, {
      headerName: 'Finish',
      width: 200,
      field: 'finishString'
    }];
  }

  ngOnDestroy(): void {
    $(window).off('resize');
  }

  private setGridHeight(): void {
    $('app-iterations ag-grid-ng2').height(($(window).height() - $('app-header').height() - 86) * 0.6);
  }

  private fetchIterations(afterAction, afterActionParams): void {
    this.iterationsService.getIterations()
      .subscribe(
        (iterations: Iteration[]) => {
          iterations.forEach((iteration: Iteration) => {
            this.id_map[iteration.id] = iteration;
          });
          this.iterations = iterations;
          if (afterAction) {
            afterAction.call(this, afterActionParams);
          }
        });
  }

  private applyNavigation(params: Map<string, string>): void {
    let iterationId: string = params['iteration'];
    if (this.iterations) {
      this.setSelection(iterationId);
    } else {
      this.fetchIterations(this.setSelection, iterationId);
    }
    this.editing = params['release'] != null;
  }

  gridReady(): void {
    let self: IterationsComponent = this;
    let menu = {
      selector: '.iteration',
      items: {
        edit: {
        name: 'Edit',
          callback: function(key, opt) { self.editItem(self.getItem(this)); }
        }
      }
    };
    if (this.user.canChangeRelease()) {
      menu['items']['deleteItem'] = {
        name: 'Delete',
        callback: function(key, opt) { self.deleteItem(self.getItem(this)); }
      };
    }
    menu['items']['plan'] = {
      name: 'Plan',
      callback: function(key, opt) { self.planItem(self.getItem(this)); }
    };
    $.contextMenu(menu);
  }

  getRowClass(rowItem: any): string {
    return 'iteration id-' + rowItem.data.id;
  }

  private getItem(jQueryObject: any): Iteration {
    let result: string = null;
    $.each(jQueryObject.attr('class').toString().split(' '), function (i: number, className: string) {
      if (className.indexOf('id-') === 0) {
        result = className.substring(3);
      }
    });
    return this.id_map[result];
  }

  editItem(model: Iteration): void {
      this.editIteration(model);
  }

  deleteItem(model: Iteration): void {
    let self: IterationsComponent = this;
    const modalRef: NgbModalRef = this.modalService.open(ConfirmationDialogComponent);
    let component: ConfirmationDialogComponent = modalRef.componentInstance;
    component.confirmDelete('Iteration', model.name);
    modalRef.result.then(
      (result: any) => {
        if (component.model.confirmed) {
          self.deleteIteration(model);
        }
      }
    );
  }

  planItem(model: Iteration): void {
    this.router.navigate(['stories', {iteration: model.id}]);
  }

  private setSelection(iterationId: string): void {
    if (iterationId) {
      if (iterationId === 'New') {
        let lastIteration = this.iterations.length > 0 ? this.iterations[this.iterations.length - 1] : null;
        this.selection = Iteration.getNext(lastIteration);
      } else {
        this.iterations.forEach((iteration: Iteration) => {
          if (String(iteration.id) === iterationId) {
            this.selection = iteration;
          }
        });
      }
    } else {
      this.selection = null;
    }
  }

  addIteration(): void {
    this.router.navigate(['schedule', {iteration: 'New'}]);
  }

  editRow(event): void {
    this.editIteration(event.data);
  }

  editIteration(iteration: Iteration): void {
    this.router.navigate(['schedule', {iteration: iteration.id}]);
  }

  deleteIteration(iteration: Iteration): void {
    this.iterationsService.delete(iteration).subscribe(
      (task: any) => {
        this.iterations.splice(this.iterations.indexOf(iteration), 1);
        this.iterations = this.iterations.slice(0); // Force ag-grid to deal with change in rows
      }
    );
  }

  get context(): any {
    return {
      me: this.user,
      gridHolder: this
    };
  }

  finishedEditing(result: FinishedEditing): void {
    if (this.selection) {
      if (this.selection.added) {
        this.selection.added = false;
        this.iterations.push(this.selection);
        this.id_map[this.selection.id] = this.selection;
        this.gridOptions.api.setRowData(this.iterations);
      } else {
        this.gridOptions.api.refreshView();
      }
    }
    switch (result) {
      case FinishedEditing.AddAnother:
        this.setSelection('New');
        break;
      case FinishedEditing.Save:
      case FinishedEditing.Cancel:
        this.router.navigate(['schedule']);
        break;
    }
  }
}
