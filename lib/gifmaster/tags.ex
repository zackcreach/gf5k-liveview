defmodule Gifmaster.Tags do
  use Ecto.Schema

  import Ecto.Changeset

  schema "tags" do
    field :name, :string
  end

  def changeset(tag, params \\ %{}) do
    tag
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
