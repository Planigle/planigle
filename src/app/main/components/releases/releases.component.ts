import { Component, AfterViewInit, OnDestroy } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { GridOptions } from 'ag-grid/main';
import { ReleaseActionsComponent } from '../release-actions/release-actions.component';
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
export class ReleasesComponent implements AfterViewInit, OnDestroy {
  public gridOptions: GridOptions = <GridOptions>{};
  public columnDefs: any[] = [];
  public releases: Release[] = null;
  public selection: Release;
  public user: Individual;

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private sessionsService: SessionsService,
    private releasesService: ReleasesService
  ) { }

  ngAfterViewInit(): void {
    this.setGridHeight();
    $(window).resize(this.setGridHeight);
    this.user = new Individual(this.sessionsService.getCurrentUser());
    this.route.params.subscribe((params: Map<string, string>) => this.applyNavigation(params));
    this.columnDefs = [{
      headerName: '',
      width: this.user.canChangeRelease() ? 54 : 36,
      field: 'blank',
      cellRendererFramework: ReleaseActionsComponent,
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
  }

  ngOnDestroy(): void {
    $(window).off('resize');
  }

  private setGridHeight(): void {
    $('app-releases ag-grid-ng2').height(($(window).height() - $('app-header').height() - 69) * 0.4);
  }

  private fetchReleases(afterAction, afterActionParams): void {
    this.releasesService.getReleases()
      .subscribe(
        (releases: Release[]) => {
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
