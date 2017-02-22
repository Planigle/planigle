/* tslint:disable:no-unused-variable */

import { TestBed, async, inject } from '@angular/core/testing';
import { DragDropService } from './drag-drop.service';

describe('DragDropService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [DragDropService]
    });
  });

  it('should ...', inject([DragDropService], (service: DragDropService) => {
    expect(service).toBeTruthy();
  }));
});
