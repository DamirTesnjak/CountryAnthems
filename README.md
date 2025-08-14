# Country Anthems

An interactive app to explore and guess countries.

---

## Installation

Clone the repository:

```bash
git clone https://github.com/DamirTesnjak/CountryAnthems
```

---

## Running with Docker

1. Install a Docker provider, e.g. **[Docker](https://www.docker.com/)**.
2. Start the container:

   ```bash
   docker-compose up
   ```

3. To rebuild after source code changes:

   ```bash
   docker-compose up --build
   ```

4. Open the app in your browser:  
   [http://localhost:4000](http://localhost:4000)

---

## Usage

The app offers two modes:

- **Explorer Mode** – Select a country to hear its anthem.
- **Game Mode** – Guess the country on a map; if correct, its anthem plays.

Language: **English**

---

## Data Sources

- **Flags:** [flagpedia.net](https://flagpedia.net/)
- **Anthems:** [nationalanthems.info](https://nationalanthems.info/)
- **Country Borders:** Obtained from [overpass-turbo.eu](https://overpass-turbo.eu/) using:

```
[out:json][timeout:180];
relation
["boundary"="administrative"]
["admin_level"="2"]
["ISO3166-1"~"."];
out geom;
```
