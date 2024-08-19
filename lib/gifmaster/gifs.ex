defmodule Gifmaster.Gifs do
  use Ecto.Schema

  import Ecto.Changeset

  schema "gifs" do
    field :name, :string
    field :file, :map
    field :tags, {:array, :string}
  end

  def changeset(gif, params \\ %{}) do
    gif
    |> cast(params, [:name, :file, :tags])
    |> validate_required([:name, :file, :tags])
  end
end
