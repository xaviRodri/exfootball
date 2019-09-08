defmodule Exfootball.Match do
  @moduledoc """
  This module represents the data model related to a football match.

  The following attributes describe a match:
    Home Team, Away Team, Season, Division, Date

  Also, we have the details of a match:
    Full Time Home Team Goals
    Full Time Away Team Goals
    Full Time Result
    Half Time Home Team Goals
    Half Time Away Team Goals
    Half Time Result
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :home_team,
             :away_team,
             :season,
             :division,
             :date,
             :fthg,
             :ftag,
             :ftr,
             :hthg,
             :htah,
             :htr
           ]}
  schema "matches" do
    # Date of the match
    field(:date, :date)
    # Full Time Home Team Goals
    field(:fthg, :integer)
    # Full Time Away Team Goals
    field(:ftag, :integer)
    # Full Time Result (H=Home Win, D=Draw, A=Away Win)
    field(:ftr, :string)
    # Half Time Home Team Goals
    field(:hthg, :integer)
    # Half Time Away Team Goals
    field(:htag, :integer)
    # Half Time Result (H=Home Win, D=Draw, A=Away Win)
    field(:htr, :string)

    belongs_to(:division, Exfootball.Division)
    belongs_to(:season, Exfootball.Season)
    belongs_to(:home_team, Exfootball.Team)
    belongs_to(:away_team, Exfootball.Team)
  end

  def changeset(%Exfootball.Match{} = match, attrs \\ %{}) do
    match
    |> cast(attrs, [
      :date,
      :fthg,
      :ftag,
      :ftr,
      :hthg,
      :htag,
      :htr
    ])
    |> validate_required([
      :date,
      :fthg,
      :ftag,
      :ftr,
      :hthg,
      :htag,
      :htr
    ])
    |> put_assoc(:away_team, attrs.away_team)
    |> put_assoc(:home_team, attrs.home_team)
    |> put_assoc(:season, attrs.season)
    |> put_assoc(:division, attrs.division)
  end
end
