import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { MapBox } from './components/map-box/map-box';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, MapBox],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  protected title = 'storm-tracker';
}
