defmodule Gifmaster.Utils.UXID do
  @moduledoc """
  Generates UXIDs and acts as an Ecto ParameterizedType
  User eXperience focused IDentifiers (UXIDs) are identifiers which:
  * Describe the resource (aid in debugging and investigation)
  * Work well with copy and paste (double clicking selects the entire ID)
  * Are secure against enumeration attacks
  """

  use Ecto.ParameterizedType

  @type t() :: String.t()
  @type prefix :: String.t() | atom

  @spec generate(prefix :: prefix) :: {:ok, t()}
  @doc """
  Returns a UXID string along with response status.
  """
  def generate(prefix) do
    {:ok, "#{prefix}_#{String.replace(Ecto.UUID.generate(), "-", "")}"}
  end

  @spec generate!(prefix :: prefix) :: t()
  @doc """
  Returns an unwrapped UXID string.
  """
  def generate!(prefix) do
    {:ok, uxid} = generate(prefix)
    uxid
  end

  @spec sigil_x(String.t(), keyword()) :: String.t()
  @doc """
  Create a UXID prefixed string.

  ```elixir
  "user" <> _identifier = ~x/user/
  "account" <> _identifier = ~x/account/
  ```
  """
  def sigil_x(prefix, _opts) do
    generate!(prefix)
  end

  @impl Ecto.ParameterizedType
  @doc """
  Generates a loaded version of the UXID.
  """
  def autogenerate(opts) do
    prefix = Map.get(opts, :prefix)
    __MODULE__.generate!(prefix)
  end

  @impl Ecto.ParameterizedType
  @doc """
  Returns the underlying schema type for a UXID.
  """
  def type(_opts), do: :string

  @impl Ecto.ParameterizedType
  @doc """
  Converts the options specified in the field macro into parameters to be used in other callbacks.
  """
  def init(opts) do
    Enum.into(opts, %{})
  end

  @impl Ecto.ParameterizedType
  @doc """
  Casts the given input to the UXID ParameterizedType with the given parameters.
  """
  def cast(data, _params), do: {:ok, data}

  @impl Ecto.ParameterizedType
  @doc """
  Loads the given term into a UXID.
  """
  def load(data, _loader, _params), do: {:ok, data}

  @impl Ecto.ParameterizedType
  @doc """
  Dumps the given term into an Ecto native type.
  """
  def dump(data, _dumper, _params), do: {:ok, data}
end
