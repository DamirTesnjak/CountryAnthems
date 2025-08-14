# Country Anthems

An interactive app to explore and guess national anthems.

## Installation

Clone this repository

> git clone https://github.com/DamirTesnjak/CountryAnthems

### Running with the docker container

- Install any docker hosting provider, such as **[Docker](https://www.docker.com/)**

- Run in terminal

  > docker-compose up

- Use

  > docker-compose up --build

  when you made changes in original source code

- Visit the app at http://localhost:4000

## Usage

The app has two modes:

- explorer mode, select a country for anthem to be played
- game mode, guess the country on a map. On correct selection the anthem plays

App supports English language

## Data

Sources:

Flags: https://flagpedia.net/
Anthems: https://nationalanthems.info/

Country borders was aquired from https://overpass-turbo.eu/ with the following query:

[out:json][timeout:180];
relation
["boundary"="administrative"]
["admin_level"="2"]
["ISO3166-1"~"."]; // Only countries with ISO code
out geom;
