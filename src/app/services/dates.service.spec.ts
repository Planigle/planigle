/* tslint:disable:no-unused-variable */

import { TestBed, async, inject } from '@angular/core/testing';
import { DatesService } from './dates.service';

describe('DatesService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [DatesService]
    });
  });

  it('should ...', inject([DatesService], (service: DatesService) => {
    expect(service).toBeTruthy();
  }));
});
