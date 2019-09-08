defmodule ExfootballWeb.MatchController do
  use ExfootballWeb, :controller

  @doc """
  Gets a list of pairs matching a season and a division,
  and returns them as JSON.
  """
  def get_pairs(conn, %{"season" => season, "division" => division}) do
    results = Exfootball.get_matches_from_season(season, division)
    json(conn, %{results: results})
  end

  @doc """
  Gets a list of pairs matching a season,
  and returns them as JSON.
  """
  def get_pairs(conn, %{"season" => season}) do
    results = Exfootball.get_matches_from_season(season)
    json(conn, %{results: results})
  end

  def get_pair_detail(conn, %{
        "division" => division,
        "season" => season,
        "away_team" => away_team,
        "home_team" => home_team
      }) do
    result = Exfootball.get_match_detail(division, season, away_team, home_team)
    json(conn, %{detail: result})
  end
end
