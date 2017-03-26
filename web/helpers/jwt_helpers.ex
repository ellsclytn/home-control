defmodule Thermio.JWTHelpers do
  require Logger
  import Joken, except: [verify: 1]

  @doc """
  use for future verification, eg. on socket connect
  """
  def verify(jwt) do
    verify()
    |> with_signer(hs256(System.get_env("APP_SECRET")))
    |> with_compact_token(jwt)
    |> Joken.verify
  end

  @doc """
  use for verification via plug
  issuer should be our auth0 domain
  app_metadata must be present in id_token
  """
  def verify do
    %Joken.Token{}
    |> Joken.with_signer(hs256(System.get_env("APP_SECRET")))
    |> Joken.with_json_module(Poison)
  end

  @doc """
  Return error message for `on_error`
  """
  def error(conn, _msg) do
    {conn, %{:errors => %{:detail => "Unauthorized"}}}
  end
end
