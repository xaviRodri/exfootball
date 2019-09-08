# Exfootball

Exfootball is an app that gets you into football results!

## Installation

Inside this Docker we will have: 
 
  * A MySQL Database (docker service: db)
  * An Elixir image (latest version if available) with PhoenixFramework installed (docker service: api)

To setup and run the API service, we have to run the following commands inside the project folder:

  * `docker-compose build` - this will create the Elixir + Phoenix container
  * `docker-compose up db` (add `-d` flag if don't want to see the logs) - this command will run the db service.
  * `docker-compose run api mix setup` - here we will insert into the database the `Data.csv` file so we can get the info from it. If fails we should retry, maybe the database is not available yet.
  * `docker-compose up api` - finally, here we are running the server. After it finishes, we could access to the endpoints.

## API

In Exfootball API, we can access the following endoints:

  * `/api/v1/pairs/` - this endpoint allows us to get a list of matches. We can filter them by division and season, or only season. E.g. `http://localhost:4000/api/v1/pairs?season=201617` or `http://localhost:4000/api/v1/pairs?season=201617&division=SP1`.
  * `/api/v1/detail/` - this other endpoint allows us to get the detail of a match. We must pass the `season`, the `division`, the `away_team` and the `home_team` in order to get a result. E.g. `http://localhost:4000/api/v1/detail?season=201617&division=SP1&home_team=Malaga&away_team=Osasuna`, and we will get something like: `{"detail":{"away_team":"Osasuna","date":"2016-08-19","div":"SP1","ftag":1,"fthg":1,"ftr":"D","home_team":"Malaga","htag":0,"hthg":0,"htr":"D","season":201617}}`.