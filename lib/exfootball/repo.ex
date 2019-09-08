defmodule Exfootball.Repo do
  use Ecto.Repo,
    otp_app: :exfootball,
    adapter: Ecto.Adapters.MyXQL
end
