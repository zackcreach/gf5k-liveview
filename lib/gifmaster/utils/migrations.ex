defmodule Gifmaster.Utils.Migrations do
  use Publicist

  defp gen_fragment(prefix) do
    "('#{prefix}_' || substr(replace(gen_random_uuid()::text, '-', ''), 0, 20))"
  end

  @doc """
   This macro tells Postgres to generate a unique prefixed UXID when a record is
   inserted.
  """
  defmacro id(prefix) do
    quote do
      add(:id, :text,
        primary_key: true,
        default:
          unquote(gen_fragment(prefix))
          |> fragment
      )
    end
  end

  defmacro __using__(_opts) do
    quote do
      use Ecto.Migration
      import Gifmaster.Utils.Migrations
    end
  end
end
