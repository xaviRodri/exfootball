defmodule Exfootball.Repo.Migrations.InitialMigration do
  use Ecto.Migration

  def change do
    create table("divisions") do
      add(:name, :string)
    end

    create table("seasons") do
      add(:name, :integer)
    end

    create table("teams") do
      add(:name, :string)
    end

    create table("matches") do
      add(:date, :date)
      add(:fthg, :integer)
      add(:ftag, :integer)
      add(:ftr, :string, length: 1)
      add(:hthg, :integer)
      add(:htag, :integer)
      add(:htr, :string, length: 1)

      add(:division_id, references(:divisions))
      add(:season_id, references(:seasons))
      add(:away_team_id, references(:teams))
      add(:home_team_id, references(:teams))
    end
  end
end
