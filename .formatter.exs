[
  import_deps: [:ecto, :phoenix, :ecto_enum, :eggnog, :grpc],
  inputs: [
    "*.{heex,ex,exs}",
    "priv/*/seeds.exs",
    "{config,lib,test}/**/*.{heex,ex,exs}",
    "storybook/**/*.exs"
  ],
  # https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.HTMLFormatter.html
  # VSCode frens might need additional configuration: https://pragmaticstudio.com/tutorials/formatting-heex-templates-in-vscode
  plugins: [Phoenix.LiveView.HTMLFormatter],
  subdirectories: ["priv/*/migrations"],
  line_length: 120,
  heex_line_length: 300
]
