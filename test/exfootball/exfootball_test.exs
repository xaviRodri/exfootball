defmodule ExfootballTest do
  use ExUnit.Case

  alias Ecto.Adapters.SQL

  setup do
    # Explicitly get a connection before each test
    :ok = SQL.Sandbox.checkout(Exfootball.Repo)
  end

  describe "find_or_create_team/1" do
    test "When the entry does not exist, creates it and returns the result" do
      assert {:ok, %Exfootball.Team{}} = Exfootball.find_or_create_team("Arsenal")
    end

    test "When the entry exists, returns it" do
      new_team =
        Exfootball.Team.changeset(%Exfootball.Team{}, %{name: "Manchester United"})
        |> Exfootball.Repo.insert()

      assert {:ok, %Exfootball.Team{}} = new_team

      assert new_team == Exfootball.find_or_create_team("Manchester United")
    end
  end

  describe "find_or_create_season/1" do
    test "When the entry does not exist, creates it and returns the result" do
      assert {:ok, %Exfootball.Season{}} = Exfootball.find_or_create_season(201_718)
    end

    test "When the entry exists, returns it" do
      new_season =
        Exfootball.Season.changeset(%Exfootball.Season{}, %{name: 201_819})
        |> Exfootball.Repo.insert()

      assert {:ok, %Exfootball.Season{}} = new_season

      assert new_season == Exfootball.find_or_create_season(201_819)
    end
  end

  describe "find_or_create_division/1" do
    test "When the entry does not exist, creates it and returns the result" do
      assert {:ok, %Exfootball.Division{}} = Exfootball.find_or_create_division("SP1")
    end

    test "When the entry exists, returns it" do
      new_division =
        Exfootball.Division.changeset(%Exfootball.Division{}, %{name: "SP2"})
        |> Exfootball.Repo.insert()

      assert {:ok, %Exfootball.Division{}} = new_division

      assert new_division == Exfootball.find_or_create_division("SP2")
    end
  end

  describe "add_match/1" do
    test "Adding a match returns a success" do
      match = %{
        "AwayTeam" => "Eibar",
        "Date" => "19/08/2016",
        "Div" => "SP1",
        "FTAG" => "1",
        "FTHG" => "2",
        "FTR" => "H",
        "HTAG" => "0",
        "HTHG" => "0",
        "HTR" => "D",
        "HomeTeam" => "La Coruna",
        "Season" => "201617"
      }

      assert {:ok, %Exfootball.Match{}} = Exfootball.add_match(match)
    end
  end

  describe "add_matches/1" do
    test "Adding 2 matches returns a list of success" do
      matches = [
        %{
          "AwayTeam" => "Eibar",
          "Date" => "19/08/2016",
          "Div" => "SP1",
          "FTAG" => "1",
          "FTHG" => "2",
          "FTR" => "H",
          "HTAG" => "0",
          "HTHG" => "0",
          "HTR" => "D",
          "HomeTeam" => "La Coruna",
          "Season" => "201617"
        },
        %{
          "AwayTeam" => "Real Madrid",
          "Date" => "01/05/2017",
          "Div" => "SP1",
          "FTAG" => "0",
          "FTHG" => "0",
          "FTR" => "D",
          "HTAG" => "0",
          "HTHG" => "0",
          "HTR" => "D",
          "HomeTeam" => "FC Barcelona",
          "Season" => "201617"
        }
      ]

      assert [{:ok, {:ok, _}}, {:ok, {:ok, _}}] = Exfootball.add_matches(matches)
    end

    test "Adding 2 matches with some bad param returns a failure" do
      matches = [
        %{
          "AwayTeam" => "",
          "Date" => "19/08/2016",
          "Div" => "SP1",
          "FTAG" => "1",
          "FTHG" => "2",
          "FTR" => "H",
          "HTAG" => "0",
          "HTHG" => "0",
          "HTR" => "D",
          "HomeTeam" => "La Coruna",
          "Season" => "201617"
        },
        %{
          "AwayTeam" => "Real Madrid",
          "Date" => "01/05/2017",
          "Div" => "SP1",
          "FTAG" => "0",
          "FTHG" => "0",
          "FTR" => "D",
          "HTAG" => "0",
          "HTHG" => "0",
          "HTR" => "D",
          "HomeTeam" => "FC Barcelona",
          "Season" => "201617"
        }
      ]

      assert [{:ok, {:error, _}}, {:ok, {:ok, _}}] = Exfootball.add_matches(matches)
    end
  end

  describe "get_matches_from_season/1" do
    test "When a season is introduced, it returns the list of pairs" do
      # First we create a match
      match = %{
        "AwayTeam" => "Eibar",
        "Date" => "19/08/2016",
        "Div" => "SP1",
        "FTAG" => "1",
        "FTHG" => "2",
        "FTR" => "H",
        "HTAG" => "0",
        "HTHG" => "0",
        "HTR" => "D",
        "HomeTeam" => "La Coruna",
        "Season" => "201617"
      }

      Exfootball.add_match(match)

      # Then we try to get the match
      assert [["SP1", 201_617, ~D[2016-08-19], "La Coruna", "Eibar"]] ==
               Exfootball.get_matches_from_season("201617")
    end

    test "When a non existent season is introduced, it returns an empty list" do
      # Then we try to get the match
      assert [error: "no matches found"] ==
               Exfootball.get_matches_from_season("201011")
    end
  end

  describe "get_matches_from_season/2" do
    test "When a season and a division are introduced, it returns the list of pairs" do
      # First we create a match
      match = %{
        "AwayTeam" => "Eibar",
        "Date" => "19/08/2016",
        "Div" => "SP1",
        "FTAG" => "1",
        "FTHG" => "2",
        "FTR" => "H",
        "HTAG" => "0",
        "HTHG" => "0",
        "HTR" => "D",
        "HomeTeam" => "La Coruna",
        "Season" => "201617"
      }

      Exfootball.add_match(match)

      # Then we try to get the match
      assert [["SP1", 201_617, ~D[2016-08-19], "La Coruna", "Eibar"]] ==
               Exfootball.get_matches_from_season("201617", "SP1")
    end

    test "When a non existent division is introduced, it returns an empty list" do
      # Then we try to get the match
      assert [error: "no matches found"] ==
               Exfootball.get_matches_from_season("201011")
    end
  end

  describe "get_match_detail/4" do
    test "When requesting a match detail, it returns them" do
      # First we create a match
      match = %{
        "AwayTeam" => "Eibar",
        "Date" => "19/08/2016",
        "Div" => "SP1",
        "FTAG" => "1",
        "FTHG" => "2",
        "FTR" => "H",
        "HTAG" => "0",
        "HTHG" => "0",
        "HTR" => "D",
        "HomeTeam" => "La Coruna",
        "Season" => "201617"
      }

      Exfootball.add_match(match)

      # Then we try to get the match
      assert %{
               away_team: "Eibar",
               date: ~D[2016-08-19],
               div: "SP1",
               ftag: 1,
               fthg: 2,
               ftr: "H",
               home_team: "La Coruna",
               htag: 0,
               hthg: 0,
               htr: "D",
               season: 201_617
             } ==
               Exfootball.get_match_detail("SP1", "201617", "Eibar", "La Coruna")
    end

    test "When requesting a match detail with some bad param, it returns a failure" do
      # We try to get the match
      assert %{error: "no match found"} ==
               Exfootball.get_match_detail("SP1", "201617", "Eibar", "La Coruna")
    end
  end
end
