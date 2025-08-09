import { Component, inject } from '@angular/core';
import { WebSocketService } from '../../webSocket.service'
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-map-box',
  imports: [],
  templateUrl: './map-box.html',
  styleUrl: './map-box.scss'
})
export class MapBox {

  private websocketService = inject(WebSocketService);
  private map!: any;
  private wsSub!: Subscription;
  private geoJson!: any;

  async ngAfterViewInit() {
    if (typeof window !== 'undefined') {
      const L = await import('leaflet');
      this.initMap(L);
      this.connectToWebSocket(L);
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

    this.geoJson = L.geoJSON(countries, {
      onEachFeature: function (feature: any, layer: any) {
        // Make layer interactive
        layer.on('click', function (e) {
          const countryName = feature.properties.name;
          console.log('Country clicked:', countryName);
          // Optionally do more, like styling or popup
        });
        layer.on('mouseover', this.highlightCountry);
        layer.on('mouseout', this.resetHighlight);
      }
    }).addTo(this.map)
  }

  highlightCountry(e) {
    var layer = e.target;

    layer.setStyle({
      weight: 5,
      color: '#666',
      dashArray: '',
      fillOpacity: 0.7
    });

    layer.bringToFront();
  }

  resetHighlight(e) {
    this.geoJson.resetStyle(e.target);
  }

  connectToWebSocket(L: any) {
    this.wsSub = this.websocketService.connect().subscribe(msg => {
      console.log('data', msg);
    });;
    // this.addStrike(L, lat, lng);
  }

  addStrike(L: any, lat: number, lng: number) {
    L.circleMarker([lat, lng], { color: 'red', radius: 5 }).addTo(this.map);
  }

  ngOnDestroy(): void {
    this.wsSub?.unsubscribe();
    this.websocketService.close();
  }
}
