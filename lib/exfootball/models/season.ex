defmodule Exfootball.Season do
  @moduledoc """
  This module represents the data model related to a football season.

  We have the following seasons in the data given:
    201516 (2015-2016) and 201617 (2016-2017)
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name]}
  schema "seasons" do
    field(:name, :integer)
  end

  def changeset(%Exfootball.Season{} = season, attrs \\ %{}) do
    season
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
