/* tslint:disable:no-unused-variable */

import { TestBed, async, inject } from '@angular/core/testing';
import { IterationsService } from './iterations.service';

describe('IterationsService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [IterationsService]
    });
  });

  it('should ...', inject([IterationsService], (service: IterationsService) => {
    expect(service).toBeTruthy();
  }));
});
