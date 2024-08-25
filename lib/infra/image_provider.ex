defmodule Infra.ImageProvider do
  use Tesla, only: [:get]

  def upload_to_s3(filename, file_binary) do
  end
end
