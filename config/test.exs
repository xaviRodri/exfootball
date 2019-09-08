use Mix.Config

# Configure your database
config :exfootball, Exfootball.Repo,
  username: "root",
  password: "root",
  database: "exfootball_test",
  hostname: "db",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :exfootball, ExfootballWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
