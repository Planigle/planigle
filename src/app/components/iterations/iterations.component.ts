import { Component, AfterViewInit } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { GridOptions } from 'ag-grid/main';
import { IterationActionsComponent } from '../iteration-actions/iteration-actions.component';
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
export class IterationsComponent implements AfterViewInit {
  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private sessionsService: SessionsService,
    private iterationsService: IterationsService
  ) {}

  public gridOptions: GridOptions = <GridOptions>{};
  public columnDefs: any[] = [{
    headerName: '',
    width: 54,
    field: 'blank',
    cellRendererFramework: IterationActionsComponent,
    suppressMovable: true,
    suppressResize: true,
    suppressSorting: true
  }, {
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
  public iterations: Iteration[] = null;
  public selection: Iteration;
  public user: Individual;
    
  ngAfterViewInit(): void {
    let self = this;
    this.setGridHeight();
    $(window).resize(this.setGridHeight);
    this.user = new Individual(this.sessionsService.getCurrentUser());
    this.route.params.subscribe((params:Map<string,string>) => this.applyNavigation(params));
  }
    
  ngOnDestroy(): void {
    $(window).off('resize');
  }
  
  private setGridHeight(): void {
    $('app-iterations ag-grid-ng2').height(($(window).height() - $('app-header').height() - 70) * 0.6);
  }
  
  private fetchIterations(afterAction, afterActionParams): void {
    this.iterationsService.getIterations()
      .subscribe(
        (iterations: Iteration[]) => {
          this.iterations = iterations;
          if(afterAction) {
            afterAction.call(this, afterActionParams);
          }
        });
  }
    
  private applyNavigation(params: Map<string,string>): void {
    let iterationId: string = params['iteration'];
    if(this.iterations) {
      this.setSelection(iterationId);
    } else {
      this.fetchIterations(this.setSelection, iterationId);
    }
  }
  
  private setSelection(iterationId: string): void {
    if(iterationId) {
      if(iterationId === 'New') {
        let lastIteration = this.iterations.length > 0 ? this.iterations[this.iterations.length - 1] : null;
        this.selection = Iteration.getNext(lastIteration);
      } else {
        this.iterations.forEach((iteration: Iteration) => {
          if(String(iteration.id) === iterationId) {
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
  
  private editRow(event): void {
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
