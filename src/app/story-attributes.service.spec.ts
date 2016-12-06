/* tslint:disable:no-unused-variable */

import { TestBed, async, inject } from '@angular/core/testing';
import { StoryAttributesService } from './story-attributes.service';

describe('StoryAttributesService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [StoryAttributesService]
    });
  });

  it('should ...', inject([StoryAttributesService], (service: StoryAttributesService) => {
    expect(service).toBeTruthy();
  }));
});
