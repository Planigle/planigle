/* tslint:disable:no-unused-variable */

import { TestBed, async, inject } from '@angular/core/testing';
import { SurveysService } from './surveys.service';

describe('SurveysService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [SurveysService]
    });
  });

  it('should ...', inject([SurveysService], (service: SurveysService) => {
    expect(service).toBeTruthy();
  }));
});
