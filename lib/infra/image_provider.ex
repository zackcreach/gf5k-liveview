defmodule Infra.ImageProvider do
  use Tesla, only: [:get]

  def upload_to_s3(filename, file_binary) do
    IO.puts(filename, file_binary)
  end
end
