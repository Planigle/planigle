/* tslint:disable:no-unused-variable */
import { async, ComponentFixture, TestBed } from '@angular/core/testing';
import { By } from '@angular/platform-browser';
import { DebugElement } from '@angular/core';

import { IterationsComponent } from './iterations.component';

describe('IterationsComponent', () => {
  let component: IterationsComponent;
  let fixture: ComponentFixture<IterationsComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ IterationsComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(IterationsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
