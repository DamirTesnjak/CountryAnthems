import { Component, inject } from '@angular/core';
import { Subscription } from 'rxjs';
import { CountryService } from './getCountries.service';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-map-box',
  imports: [],
  templateUrl: './map-box.html',
  styleUrl: './map-box.scss'
})
export class MapBox {

  private map!: any;
  private wsSub!: Subscription;
  private geoJson!: any;
  private countryService = inject(CountryService);

  async ngAfterViewInit() {
    if (typeof window !== 'undefined') {
      const L = await import('leaflet');
      this.initMap(L);
    }
  }

  private initMap(L: any): void {
    this.map = L.map('map', {
      center: [46.0651538, 14.4644706], // Set your starting position
      zoom: 13
    });

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 18,
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(this.map);

    this.map.on('click', (e: any) => this.onMapClick(e))
  }

  highlightCountry(e: any) {
    var layer = e.target;

    layer.setStyle({
      weight: 5,
      color: '#666',
      dashArray: '',
      fillOpacity: 0.7
    });

    layer.bringToFront();
  }

  onMapClick(e: any) {
    const { lat, lng } = e.latlng;
    const bodyReq = {
      lat,
      lng
    }
    this.countryService.getCountry(bodyReq).subscribe({
      next: (data) => {
        console.log('Response:', data);
      },
      error: (err) => {
        console.error('Error:', err);
      },
    });
  }

  resetHighlight(e: any) {
    this.geoJson.resetStyle(e.target);
  }

  addStrike(L: any, lat: number, lng: number) {
    L.circleMarker([lat, lng], { color: 'red', radius: 5 }).addTo(this.map);
  }

  ngOnDestroy(): void {
    this.wsSub?.unsubscribe();
  }
}
