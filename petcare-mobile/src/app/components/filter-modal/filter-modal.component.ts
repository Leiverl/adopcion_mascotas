import { Component, Input, OnInit, inject } from '@angular/core';
import { IonicModule, ModalController } from '@ionic/angular';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-filter-modal',
  standalone: true,
  imports: [IonicModule, ReactiveFormsModule, CommonModule],
  templateUrl: './filter-modal.component.html',
})
export class FilterModalComponent implements OnInit {
  @Input() currentFilters: any = {};

  private modalCtrl = inject(ModalController);
  private fb = inject(FormBuilder);
  
  filterForm: FormGroup = this.fb.group({
    especie: [null],
    tamano: [null],
    sexo: [null],
  });

  ngOnInit() {
    this.filterForm.patchValue(this.currentFilters);
  }

  applyFilters() {
    this.modalCtrl.dismiss(this.filterForm.value);
  }

  clearFilters() {
    this.filterForm.reset();
    this.modalCtrl.dismiss(this.filterForm.value);
  }

  cancel() {
    this.modalCtrl.dismiss(null);
  }
}