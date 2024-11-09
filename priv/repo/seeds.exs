# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Gifmaster.Repo.insert!(%Gifmaster.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Gifmaster.Catalog

Catalog.create_gif(%{
  name: "blink 182",
  tags: ~w(wtf),
  file: %{
    url: %{
      relative: "/8e0cefa5-718d-4e44-b59e-b45f0b87398b.gif",
      absolute: "https://gems.gifmaster5000.com/8e0cefa5-718d-4e44-b59e-b45f0b87398b.gif"
    }
  }
})

Catalog.create_gif(%{
  name: "jake confused",
  tags: ~w(wait),
  file: %{
    url: %{
      relative: "c5eaab8a-42b6-4764-b206-8e14842af582.gif",
      absolute: "https://gems.gifmaster5000.com/c5eaab8a-42b6-4764-b206-8e14842af582.gif"
    }
  }
})

Catalog.create_gif(%{
  name: "chris pratt surprised",
  tags: ~w(surprised whoa),
  file: %{
    url: %{
      relative: "d7038fa0-16b1-499b-be97-3188cf4f16d5.gif",
      absolute: "https://gems.gifmaster5000.com/d7038fa0-16b1-499b-be97-3188cf4f16d5.gif"
    }
  }
})
