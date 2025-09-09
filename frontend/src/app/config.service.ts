import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import json from '../config.json';

@Injectable({ providedIn: 'root' })
export class ConfigService {
    private cfg: Record<string, any> = {};

    constructor(private http: HttpClient) { }

    async loadConfig(): Promise<void> {
        this.cfg = json;
    }

    get<T = any>(key: string): T | undefined {
        return this.cfg[key];
    }
}