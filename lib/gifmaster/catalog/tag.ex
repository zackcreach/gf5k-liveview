defmodule Gifmaster.Catalog.Tag do
  use Gifmaster.Schema

  import Ecto.Changeset

  schema "tags" do
    field :name, :string

    timestamps()
  end

  def changeset(tag, params \\ %{}) do
    tag
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
