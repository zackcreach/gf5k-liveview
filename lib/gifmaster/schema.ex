defmodule Gifmaster.Schema do
  alias Gifmaster.Utils.UXID

  defmacro __using__(_macro_args) do
    quote do
      use Ecto.Schema

      @primary_key {:id, UXID, [autogenerate: false, read_after_writes: true]}
      @foreign_key_type UXID
      @timestamps_opts [type: :utc_datetime_usec]
    end
  end
end
