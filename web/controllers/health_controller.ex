defmodule Thermio.HealthController do
  use Thermio.Web, :controller

  def health(conn, _params) do
    db_up =
      try do
        Repo.one!(from c in "climates", select: count(c.id))
        true
      rescue
        _ -> false
      end

    if db_up do
      conn
      |> put_status(:ok)
      |> json(%{status: :ok})
    else
      conn
      |> put_status(:internal_server_error)
      |> json(%{status: :internal_server_error})
    end
  end
end
