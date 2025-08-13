import { Component, ElementRef, inject, signal, ViewChild } from '@angular/core';
import { Subscription } from 'rxjs';
import { CountryService } from './getCountries.service';

@Component({
  selector: 'app-map-box',
  imports: [],
  templateUrl: './map-box.html',
  styleUrl: './map-box.scss'
})

export class MapBox {

  @ViewChild('audioPlayer') audioPlayer!: ElementRef<HTMLAudioElement>;

  private map!: any;
  private wsSub!: Subscription;
  private geoJson!: any;
  private countryService = inject(CountryService);
  private currentHighlightLayer: any = null;

  mapCountryDialog!: any;
  selectedCountry = signal({
    anthemKey: 0,
    flag: "",
    countryName: "Select a country",
    countryCapital: "",
    anthemLabel: "",
    anthemAudio: ""
  })

  async ngAfterViewInit() {
    if (typeof window !== 'undefined') {
      const L = await import('leaflet');
      this.initMap(L);
    }
  }

  private initMap(L: any): void {
    this.map = L.map('map', {
      center: [46.0651538, 14.4644706], // Set your starting position
      zoom: 5
    });

    L.tileLayer('https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}.png', {
      maxZoom: 18,
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, &copy; CartoDB'
    }).addTo(this.map);

    this.map.on('click', (e: any) => this.onMapClick(L, e))
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

  onMapClick(L: any, e: any) {
    const { lat, lng } = e.latlng;
    const bodyReq = {
      lat,
      lng
    }
    this.countryService.getCountry(bodyReq).subscribe({
      next: (data) => {
        console.log('Response:', data);

        if (this.currentHighlightLayer) {
          this.map.removeLayer(this.currentHighlightLayer);
          this.currentHighlightLayer = null;
        }

        this.currentHighlightLayer = L.geoJSON(data.geometry, { style: { color: 'green' } });
        this.currentHighlightLayer.addTo(this.map);

        this.selectedCountry.set({
          anthemKey: Date.now(),
          flag: data.flag,
          countryName: data.name,
          countryCapital: data.capitalCity,
          anthemLabel: data.anthemLabel,
          anthemAudio: data.anthemAudio
        })

        setTimeout(() => {
          const player = this.audioPlayer.nativeElement;
          player.load();
          player
            .play()
            .catch((err) => console.warn('Autoplay blocked:', err));
        }, 500);
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
