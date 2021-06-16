import { TestBed, inject } from '@angular/core/testing';

import { ContractsService } from './web3.service';

describe('Web3Service', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [ContractsService]
    });
  });

  it('should be created', inject([ContractsService], (service: ContractsService) => {
    expect(service).toBeTruthy();
  }));
});
