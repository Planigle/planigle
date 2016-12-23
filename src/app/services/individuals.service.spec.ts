/* tslint:disable:no-unused-variable */

import { TestBed, async, inject } from '@angular/core/testing';
import { IndividualsService } from './individuals.service';

describe('IndividualsService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [IndividualsService]
    });
  });

  it('should ...', inject([IndividualsService], (service: IndividualsService) => {
    expect(service).toBeTruthy();
  }));
});
