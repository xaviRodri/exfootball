defmodule Exfootball do
  @moduledoc """
  Exfootball keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  import Ecto.Query

  @doc """
  Gets the matches from the CSV files and adds them into the database.
  The CSV file must have headers to work properly.
  """
  def import_matches_from_csv(path \\ "../input_csv_files/Data.csv") do
    parse_csv(path)
    |> add_matches
  end

  @doc """
  Decode a stream of comma-separated lines into a stream of maps.
  Must have headers inside the file to work properly.
  """
  def parse_csv(path) when is_bitstring(path) do
    path
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.to_list()
  end

  @doc """
  Inserts multiple matches into the database.
  Wants a list of matches parsed from a csv file with the `parse_csv` function.
  """
  def add_matches(matches) do
    Enum.map(matches, fn match ->
      Exfootball.Repo.transaction(fn ->
        add_match(match)
      end)
    end)
  end

  @doc """
  Inserts a match into the database.
  If one of the match attributes is not in the database, it should add it too.
  """
  def add_match(%{
        "AwayTeam" => away_team,
        "HomeTeam" => home_team,
        "Season" => season,
        "Date" => date,
        "Div" => division,
        "FTAG" => ftag,
        "FTHG" => fthg,
        "FTR" => ftr,
        "HTAG" => htag,
        "HTHG" => hthg,
        "HTR" => htr
      }) do
    # First we need to know if some of the match fields are added or we have to create them
    #  So we will do find_or_create for away_team, home_team, season and division
    match_associations =
      get_match_associations(%{
        away_team: away_team,
        home_team: home_team,
        season: season,
        division: division
      })

    Exfootball.Match.changeset(
      %Exfootball.Match{},
      %{
        away_team: match_associations.away_team,
        home_team: match_associations.home_team,
        season: match_associations.season,
        division: match_associations.division,
        date: Timex.parse!(date, "{0D}/{0M}/{YYYY}"),
        ftag: ftag,
        fthg: fthg,
        ftr: ftr,
        htag: htag,
        hthg: hthg,
        htr: htr
      }
    )
    |> Exfootball.Repo.insert()
  rescue
    err -> {:error, err}
  end

  @doc """
  Gets some match details and returns a map with the IDs of each detail if finds them.
  If some of the details don't exist in the database, it will create them.
  """
  def get_match_associations(%{
        away_team: away_team,
        home_team: home_team,
        season: season,
        division: division
      }) do
    {:ok, away_team} = find_or_create_team(away_team)
    {:ok, home_team} = find_or_create_team(home_team)
    {:ok, season} = find_or_create_season(season)
    {:ok, division} = find_or_create_division(division)

    %{
      away_team: away_team,
      home_team: home_team,
      season: season,
      division: division
    }
  end

  @doc """
  Gets / Inserts an Exfootball.Team entry from / into the database.
  """
  def find_or_create_team(entry) do
    case(Exfootball.Repo.get_by(Exfootball.Team, name: entry)) do
      nil ->
        or_create_team(entry)

      result ->
        {:ok, result}
    end
  end

  @doc """
  Inserts the entry into the database.
  """
  def or_create_team(entry) do
    Exfootball.Team.changeset(%Exfootball.Team{}, %{name: entry})
    |> Exfootball.Repo.insert()
  end

  @doc """
  Gets / Inserts an Exfootball.Season entry from / into the database.
  """
  def find_or_create_season(entry) do
    case(Exfootball.Repo.get_by(Exfootball.Season, name: entry)) do
      nil ->
        or_create_season(entry)

      result ->
        {:ok, result}
    end
  end

  @doc """
  Inserts the entry into the database.
  """
  def or_create_season(entry) do
    Exfootball.Season.changeset(%Exfootball.Season{}, %{name: entry})
    |> Exfootball.Repo.insert()
  end

  @doc """
  Gets / Inserts an Exfootball.Division entry from / into the database.
  """
  def find_or_create_division(entry) do
    case(Exfootball.Repo.get_by(Exfootball.Division, name: entry)) do
      nil ->
        or_create_division(entry)

      result ->
        {:ok, result}
    end
  end

  @doc """
  Inserts the entry into the database.
  """
  def or_create_division(entry) do
    Exfootball.Division.changeset(%Exfootball.Division{}, %{name: entry})
    |> Exfootball.Repo.insert()
  end

  @doc """
  Gets a list of matches that were played in a season.
  """
  def get_matches_from_season(season) do
    season = Exfootball.Repo.get_by!(Exfootball.Season, name: season)

    query =
      from(m in "matches",
        join: s in Exfootball.Season,
        on: m.season_id == s.id,
        join: d in Exfootball.Division,
        on: m.division_id == d.id,
        join: at in Exfootball.Team,
        on: m.away_team_id == at.id,
        join: ht in Exfootball.Team,
        on: m.home_team_id == ht.id
      )

    query =
      from([m, s, d, at, ht] in query,
        where: s.id == ^season.id,
        select: [d.name, s.name, m.date, ht.name, at.name]
      )

    Exfootball.Repo.all(query)
  rescue
    _err -> "no matches found"
  end

  @doc """
  Gets a list of matches of a concrete division that were played in a season.
  """
  def get_matches_from_season(season, division) do
    season = Exfootball.Repo.get_by!(Exfootball.Season, name: season)
    division = Exfootball.Repo.get_by!(Exfootball.Division, name: division)

    query =
      from(m in "matches",
        join: s in Exfootball.Season,
        on: m.season_id == ^season.id,
        join: d in Exfootball.Division,
        on: m.division_id == d.id,
        join: at in Exfootball.Team,
        on: m.away_team_id == at.id,
        join: ht in Exfootball.Team,
        on: m.home_team_id == ht.id
      )

    query =
      from([m, s, d, at, ht] in query,
        where: s.id == ^season.id,
        where: d.id == ^division.id,
        select: [d.name, s.name, m.date, ht.name, at.name]
      )

    Exfootball.Repo.all(query)
  rescue
    _err -> "no matches found"
  end

  @doc """
  Gets the detail of a match.
  """
  def get_match_detail(division, season, away_team, home_team) do
    season = Exfootball.Repo.get_by!(Exfootball.Season, name: season)
    division = Exfootball.Repo.get_by!(Exfootball.Division, name: division)
    away_team = Exfootball.Repo.get_by!(Exfootball.Team, name: away_team)
    home_team = Exfootball.Repo.get_by!(Exfootball.Team, name: home_team)

    query =
      from(m in "matches",
        join: s in Exfootball.Season,
        on: m.season_id == ^season.id,
        join: d in Exfootball.Division,
        on: m.division_id == d.id,
        join: at in Exfootball.Team,
        on: m.away_team_id == at.id,
        join: ht in Exfootball.Team,
        on: m.home_team_id == ht.id
      )

    query =
      from([m, s, d, at, ht] in query,
        where: s.id == ^season.id,
        where: d.id == ^division.id,
        where: at.id == ^away_team.id,
        where: ht.id == ^home_team.id,
        select: %{
          div: d.name,
          season: s.name,
          date: m.date,
          home_team: ht.name,
          away_team: at.name,
          fthg: m.fthg,
          ftag: m.ftag,
          ftr: m.ftr,
          hthg: m.hthg,
          htag: m.htag,
          htr: m.htr
        }
      )

    Exfootball.Repo.one(query)
  rescue
    _err -> %{error: "no match found"}
  end
end
