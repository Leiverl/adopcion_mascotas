import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AdoptionFormPage } from './adoption-form.page';

describe('AdoptionFormPage', () => {
  let component: AdoptionFormPage;
  let fixture: ComponentFixture<AdoptionFormPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(AdoptionFormPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
