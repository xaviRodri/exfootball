defmodule Exfootball.Team do
  @moduledoc """
  This module represents the data model related to a football team.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name]}
  schema "teams" do
    field(:name, :string)
  end

  def changeset(%Exfootball.Team{} = team, attrs \\ %{}) do
    team
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
