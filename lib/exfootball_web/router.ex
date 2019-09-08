defmodule ExfootballWeb.Router do
  use ExfootballWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", ExfootballWeb do
    pipe_through(:api)

    scope "/v1" do
      get("/pairs", MatchController, :get_pairs)
      get("/detail", MatchController, :get_pair_detail)
    end
  end
end
