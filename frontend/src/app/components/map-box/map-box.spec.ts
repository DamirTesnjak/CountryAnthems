import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MapBox } from './map-box';

describe('MapBox', () => {
  let component: MapBox;
  let fixture: ComponentFixture<MapBox>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MapBox]
    })
    .compileComponents();

    fixture = TestBed.createComponent(MapBox);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
