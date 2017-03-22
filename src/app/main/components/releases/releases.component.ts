import { Component, OnInit, AfterViewInit, OnDestroy } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { GridOptions } from 'ag-grid/main';
import { ConfirmationDialogComponent } from '../confirmation-dialog/confirmation-dialog.component';
import { ReleasesService } from '../../services/releases.service';
import { SessionsService } from '../../services/sessions.service';
import { Release } from '../../models/release';
import { Individual } from '../../models/individual';
import { FinishedEditing } from '../../models/finished-editing';
declare var $: any;

@Component({
  selector: 'app-releases',
  templateUrl: './releases.component.html',
  styleUrls: ['./releases.component.css'],
  providers: [ReleasesService]
})
export class ReleasesComponent implements OnInit, AfterViewInit, OnDestroy {
  public gridOptions: GridOptions = <GridOptions>{};
  public columnDefs: any[] = [];
  public releases: Release[] = null;
  public selection: Release;
  public user: Individual;
  public editing: boolean = false;
  private id_map: Map<string, Release> = new Map();

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private modalService: NgbModal,
    private sessionsService: SessionsService,
    private releasesService: ReleasesService
  ) { }

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
    $('app-releases ag-grid-ng2').height(($(window).height() - $('app-header').height() - 86) * 0.4);
  }

  private fetchReleases(afterAction, afterActionParams): void {
    this.releasesService.getReleases()
      .subscribe(
        (releases: Release[]) => {
          releases.forEach((release: Release) => {
            this.id_map[release.id] = release;
          });
          this.releases = releases;
          if (afterAction) {
            afterAction.call(this, afterActionParams);
          }
        });
  }

  private applyNavigation(params: Map<string, string>): void {
    let releaseId: string = params['release'];
    if (this.releases) {
      this.setSelection(releaseId);
    } else {
      this.fetchReleases(this.setSelection, releaseId);
    }
    this.editing = params['iteration'] != null;
  }

  gridReady(): void {
    let self: ReleasesComponent = this;
    let menu = {
      selector: '.release',
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
    $.contextMenu('destroy');
    $.contextMenu(menu);
  }

  getRowClass(rowItem: any): string {
    return 'release id-' + rowItem.data.id;
  }

  private getItem(jQueryObject: any): Release {
    let result: string = null;
    $.each(jQueryObject.attr('class').toString().split(' '), function (i: number, className: string) {
      if (className.indexOf('id-') === 0) {
        result = className.substring(3);
      }
    });
    return this.id_map[result];
  }

  editItem(model: Release): void {
    this.editRelease(model);
  }

  deleteItem(model: Release): void {
    let self: ReleasesComponent = this;
    const modalRef: NgbModalRef = this.modalService.open(ConfirmationDialogComponent);
    let component: ConfirmationDialogComponent = modalRef.componentInstance;
    component.confirmDelete('Release', model.name);
    modalRef.result.then(
      (result: any) => {
        if (component.model.confirmed) {
          self.deleteRelease(model);
        }
      }
    );
  }

  planItem(model: Release): void {
      this.router.navigate(['stories', {release: model.id}]);
  }

  private setSelection(releaseId: string): void {
    if (releaseId) {
      if (releaseId === 'New') {
        let lastRelease = this.releases.length > 0 ? this.releases[this.releases.length - 1] : null;
        this.selection = Release.getNext(lastRelease);
      } else {
        this.releases.forEach((release: Release) => {
          if (String(release.id) === releaseId) {
            this.selection = release;
          }
        });
      }
    } else {
      this.selection = null;
    }
  }

  addRelease(): void {
    this.router.navigate(['schedule', {release: 'New'}]);
  }

  editRow(event): void {
    this.editRelease(event.data);
  }

  editRelease(release: Release): void {
    this.router.navigate(['schedule', {release: release.id}]);
  }

  deleteRelease(release: Release): void {
    this.releasesService.delete(release).subscribe(
      (task: any) => {
        this.releases.splice(this.releases.indexOf(release), 1);
        this.releases = this.releases.slice(0); // Force ag-grid to deal with change in rows
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
        this.releases.push(this.selection);
        this.id_map[this.selection.id] = this.selection;
        this.gridOptions.api.setRowData(this.releases);
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
