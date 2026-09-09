import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
database_config =
  case System.get_env("DATABASE_SOCKET_DIR") do
    socket_dir when socket_dir not in [nil, ""] ->
      [socket_dir: socket_dir]

    _socket_dir ->
      [hostname: "localhost", port: String.to_integer(System.get_env("DATABASE_PORT", "5432"))]
  end

config :gifmaster,
       Gifmaster.Repo,
       database_config ++
         [
           username: System.get_env("DATABASE_USERNAME") || "postgres",
           password: "postgres",
           database: "gifmaster_test#{System.get_env("MIX_TEST_PARTITION")}",
           pool: Ecto.Adapters.SQL.Sandbox,
           pool_size: System.schedulers_online() * 2
         ]

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gifmaster, GifmasterWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "0MPVIUpfDsksdNiyPcB4enUw1RP7rohpot0GtMDpYSHL26CzQxis1oqw74jM7lWm",
  server: false

# In test we don't send emails
config :gifmaster, Gifmaster.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
