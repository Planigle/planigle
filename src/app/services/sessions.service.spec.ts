/* tslint:disable:no-unused-variable */

import { TestBed, async, inject } from '@angular/core/testing';
import { SessionsService } from './sessions.service';

describe('SessionsService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [SessionsService]
    });
  });

  it('should ...', inject([SessionsService], (service: SessionsService) => {
    expect(service).toBeTruthy();
  }));
});
