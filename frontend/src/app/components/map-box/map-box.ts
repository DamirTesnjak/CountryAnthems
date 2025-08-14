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
  private L!: any;
  private tileLayer!: any;
  private wsSub!: Subscription;
  private countryService = inject(CountryService);
  private countryLayer: any = null;
  private guessedCountryLayer: any = null;

  mapCountryDialog!: any;

  gameMode = signal({
    gameMode: false,
  })

  showNextCountryButtonGame = signal({
    showButton: false
  })

  selectedCountry = signal({
    anthemKey: 0,
    flag: "",
    countryName: "",
    countryCapital: "",
    anthemLabel: "",
    anthemAudio: ""
  })

  countryToGuess = signal({
    anthemKey: 0,
    flag: "",
    countryName: "",
    countryCapital: "",
    anthemLabel: "",
    anthemAudio: "",
    geometry: null,
  })

  async ngAfterViewInit() {
    if (typeof window === 'undefined') {
      return;
    }
    const leafletModule = await import('leaflet');
    this.L = (leafletModule as any).default ?? leafletModule;
    this.initMap();
  }

  private initMap(): void {
    this.map = this.L.map('map', {
      center: [46.0651538, 14.4644706], // Set your starting position
      zoom: 5
    });

    this.tileLayer = this.L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 18,
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, &copy; CartoDB'
    }).addTo(this.map);

    this.map.on('click', (e: any) => this.onMapClick(e))
  }

  playAnthem() {
    setTimeout(() => {
      const player = this.audioPlayer.nativeElement;
      player.load();
      player
        .play()
        .catch((err) => console.warn('Autoplay blocked:', err));
    }, 500);
  }

  setSelectedCountry(data: any) {
    this.selectedCountry.set({
      anthemKey: Date.now(),
      flag: data.flag,
      countryName: data.name,
      countryCapital: data.capitalCity,
      anthemLabel: data.anthemLabel,
      anthemAudio: data.anthemAudio
    });
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

        if (this.countryLayer) {
          this.map.removeLayer(this.countryLayer);
          this.countryLayer = null;
        }

        if (this.guessedCountryLayer) {
          this.map.removeLayer(this.guessedCountryLayer);
          this.guessedCountryLayer = null;
        }

        if (this.gameMode().gameMode) {
          if (this.countryToGuess().countryName === data.name) {
            this.countryLayer = this.L.geoJSON(data.geometry, { style: { color: 'green' } });
            this.setSelectedCountry(data);
            this.playAnthem();
          } else {
            this.countryLayer = this.L.geoJSON(data.geometry, { style: { color: 'red' } });
            this.guessedCountryLayer = this.L.geoJSON(this.countryToGuess().geometry, { style: { color: 'blue' } });
            this.guessedCountryLayer.addTo(this.map);
          }
          this.countryLayer.addTo(this.map);
        } else {
          this.countryLayer = this.L.geoJSON(data.geometry, { style: { color: 'green' } });
          this.countryLayer.addTo(this.map);

          this.setSelectedCountry(data);
          this.playAnthem();
        }
      },
      error: (err) => {
        this.selectedCountry.set({
          anthemKey: 0,
          flag: "",
          countryName: "",
          countryCapital: "",
          anthemLabel: "",
          anthemAudio: ""
        })
        console.error('Error:', err);
      },
    });
  }

  getCountryToGuessData() {
    this.countryService.getCountryToGuess().subscribe({
      next: (data) => {
        console.log('Response:', data);

        this.countryToGuess.set({
          anthemKey: Date.now(),
          flag: data.flag,
          countryName: data.name,
          countryCapital: data.capitalCity,
          anthemLabel: data.anthemLabel,
          anthemAudio: data.anthemAudio,
          geometry: data.geometry,
        })
      },
      error: (err) => {
        this.countryToGuess.set({
          anthemKey: 0,
          flag: "",
          countryName: "",
          countryCapital: "",
          anthemLabel: "",
          anthemAudio: "",
          geometry: null
        })
        console.error('Error:', err);
      },
    });
  }

  clearMap() {
    this.selectedCountry.set({
      anthemKey: 0,
      flag: "",
      countryName: "",
      countryCapital: "",
      anthemLabel: "",
      anthemAudio: ""
    });

    this.countryToGuess.set({
      anthemKey: 0,
      flag: "",
      countryName: "",
      countryCapital: "",
      anthemLabel: "",
      anthemAudio: "",
      geometry: null
    });

    if (this.countryLayer) {
      this.map.removeLayer(this.countryLayer);
      this.countryLayer = null;
    }

    if (this.guessedCountryLayer) {
      this.map.removeLayer(this.guessedCountryLayer);
      this.guessedCountryLayer = null;
    }
  }

  onGameButtonHandler() {
    this.clearMap();
    this.gameMode.set({ gameMode: true });
    this.updateBaseMap("gameMode");
    this.getCountryToGuessData();
  }

  guessAnotherCountryHandler() {
    this.clearMap();
    this.getCountryToGuessData();
  }

  onExploreButtonHandler() {
    this.clearMap();
    this.gameMode.set({ gameMode: false });
    this.updateBaseMap("exploreMode");
  }

  private updateBaseMap(styleKey: string): void {
    if (this.tileLayer) {
      this.map.removeLayer(this.tileLayer);
    }

    const url = styleKey === 'gameMode'
      ? 'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}.png'
      : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';

    this.tileLayer = this.L.tileLayer(url, { attribution: '...' }).addTo(this.map);
  }

  ngOnDestroy(): void {
    this.wsSub?.unsubscribe();
  }
}
