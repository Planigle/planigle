/* tslint:disable:no-unused-variable */
import { async, ComponentFixture, TestBed } from '@angular/core/testing';
import { By } from '@angular/platform-browser';
import { DebugElement } from '@angular/core';

import { IterationOverallActionsComponent } from './iteration-overall-actions.component';

describe('IterationOverallActionsComponent', () => {
  let component: IterationOverallActionsComponent;
  let fixture: ComponentFixture<IterationOverallActionsComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ IterationOverallActionsComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(IterationOverallActionsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
