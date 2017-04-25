defmodule Thermio.Repo do
  use Ecto.Repo, otp_app: :thermio
  use Scrivener, page_size: 10
end
