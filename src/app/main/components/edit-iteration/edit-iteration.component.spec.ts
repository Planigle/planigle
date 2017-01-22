/* tslint:disable:no-unused-variable */
import { async, ComponentFixture, TestBed } from '@angular/core/testing';
import { By } from '@angular/platform-browser';
import { DebugElement } from '@angular/core';

import { EditIterationComponent } from './edit-iteration.component';

describe('EditIterationComponent', () => {
  let component: EditIterationComponent;
  let fixture: ComponentFixture<EditIterationComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ EditIterationComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(EditIterationComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
