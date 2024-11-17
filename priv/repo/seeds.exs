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
  name: "lil yachty drake",
  tags: ["of course", "duh", "yea"],
  file: %{
    url: %{
      relative: "/lil-yachty-drake.gif",
      absolute: "https://gems.gifmaster5000.com/lil-yachty-drake.gif"
    }
  }
})

Catalog.create_gif(%{
  name: "kombucha ugh",
  tags: ~w(ugh indecisive unless well),
  file: %{
    url: %{
      relative: "/kombucha-ugh.gif",
      absolute: "https://gems.gifmaster5000.com/kombucha-ugh.gif"
    }
  }
})

Catalog.create_gif(%{
  name: "thunk",
  tags: ~w(emoji thinking),
  file: %{
    url: %{
      relative: "/thunk.gif",
      absolute: "https://gems.gifmaster5000.com/thunk.gif"
    }
  }
})

Catalog.create_gif(%{
  name: "nod beard",
  tags: ["yes", "of course"],
  file: %{
    url: %{
      relative: "/nod-beard.gif",
      absolute: "https://gems.gifmaster5000.com/nod-beard.gif"
    }
  }
})

Catalog.create_gif(%{
  name: "blink wtf",
  tags: ~w(wtf ugh),
  file: %{
    url: %{
      relative: "/blink-wtf.gif",
      absolute: "https://gems.gifmaster5000.com/blink-wtf.gif"
    }
  }
})

Catalog.create_gif(%{
  name: "oh damn andy",
  tags: ~w(surprised shocked yes),
  file: %{
    url: %{
      relative: "/oh-damn-andy.gif",
      absolute: "https://gems.gifmaster5000.com/oh-damn-andy.gif"
    }
  }
})

Catalog.create_gif(%{
  name: "shake nod basketball",
  tags: ~w(disappointed unless),
  file: %{
    url: %{
      relative: "/shake-nod-basketball.gif",
      absolute: "https://gems.gifmaster5000.com/shake-nod-basketball.gif"
    }
  }
})

Catalog.create_gif(%{
  name: "banderas",
  tags: ~w(nice yes beautiful),
  file: %{
    url: %{
      relative: "/banderas.gif",
      absolute: "https://gems.gifmaster5000.com/banderas.gif"
    }
  }
})

Catalog.create_gif(%{
  name: "jordan wow",
  tags: ~w(michael wow disappointed),
  file: %{
    url: %{
      relative: "/jordan-wow.gif",
      absolute: "https://gems.gifmaster5000.com/jordan-wow.gif"
    }
  }
})

Catalog.create_gif(%{
  name: "wtf subway",
  tags: ~w(phone wtf),
  file: %{
    url: %{
      relative: "/wtf-subway.gif",
      absolute: "https://gems.gifmaster5000.com/wtf-subway.gif"
    }
  }
})

Catalog.create_gif(%{
  name: "my man",
  tags: ~w(denzel washington),
  file: %{
    url: %{
      relative: "/my-man.gif",
      absolute: "https://gems.gifmaster5000.com/my-man.gif"
    }
  }
})
