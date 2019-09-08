defmodule Exfootball.Division do
  @moduledoc """
  This module represents the data model related to a football division.

  We have the following divisions in the data given:
    SP1, SP2, E0 and D1
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name]}
  schema "divisions" do
    field(:name, :string)
  end

  def changeset(%Exfootball.Division{} = division, attrs \\ %{}) do
    division
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
