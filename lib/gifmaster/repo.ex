defmodule Gifmaster.Repo do
  use Ecto.Repo,
  otp_app: :gifmaster,
  adapter: Ecto.Adapters.Postgres
end
