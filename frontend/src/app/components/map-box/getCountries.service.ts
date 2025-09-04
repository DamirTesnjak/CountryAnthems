import { inject, Injectable } from "@angular/core";
import { IBodyRequest } from "./type";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";

@Injectable({
    providedIn: 'root',
})

export class CountryService {
    private http = inject(HttpClient);
    private baseUrl = (window as any).__env.apiUrl as string;

    getCountry(bodyReq: IBodyRequest): Observable<any> {
        const url = `${this.baseUrl}/which-country?lat=${bodyReq.lat}&lng=${bodyReq.lng}`;
        return this.http.get(url);
    }

    getCountryToGuess(): Observable<any> {
        const url = `${this.baseUrl}/random-country`;
        return this.http.get(url);
    }
}