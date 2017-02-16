/* tslint:disable:no-unused-variable */
import { async, ComponentFixture, TestBed } from '@angular/core/testing';
import { By } from '@angular/platform-browser';
import { DebugElement } from '@angular/core';

import { EpicsComponent } from './epics.component';

describe('EpicsComponent', () => {
  let component: EpicsComponent;
  let fixture: ComponentFixture<EpicsComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ EpicsComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(EpicsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
