import { inject, Injectable } from "@angular/core";
import { IBodyRequest } from "./type";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import { ConfigService } from "../../config.service";

@Injectable({
    providedIn: 'root',
})

export class CountryService {
    private http = inject(HttpClient);
    private configService = inject(ConfigService)
    private baseUrl = this.configService.get("apiUrl");

    getCountry(bodyReq: IBodyRequest): Observable<any> {
        const url = `${this.baseUrl}/api/which-country?lat=${bodyReq.lat}&lng=${bodyReq.lng}`;
        return this.http.get(url);
    }

    getCountryToGuess(): Observable<any> {
        const url = `${this.baseUrl}/api/random-country`;
        return this.http.get(url);
    }
}