/* tslint:disable:no-unused-variable */

import { TestBed, async, inject } from '@angular/core/testing';
import { ProjectionsService } from './projections.service';

describe('ProjectionsService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [ProjectionsService]
    });
  });

  it('should ...', inject([ProjectionsService], (service: ProjectionsService) => {
    expect(service).toBeTruthy();
  }));
});
