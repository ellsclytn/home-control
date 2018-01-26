defmodule Thermio.AuthController do
  use Thermio.Web, :controller

  def index(conn, %{"provider" => provider}) do
    redirect conn, external: authorize_url!(provider)
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    authorized_client = get_token!(provider, code)
    %{body: user} = get_user!(provider, authorized_client)

    conn
    |> put_session(:current_user, user)
    |> put_session(:access_token, authorized_client.token.access_token)
    |> redirect(to: "/")
  end

  defp authorize_url!("google") do
    Google.authorize_url!(scope: "email profile")
  end

  defp authorize_url!(_) do
    raise "No matching provider available"
  end

  defp get_token!("google", code) do
    Google.get_token!(code: code)
  end

  defp get_token!(_, _) do
    raise "No matching provider available"
  end

  defp get_user!("google", client) do
    user_url = "https://www.googleapis.com/plus/v1/people/me/openIdConnect"
    OAuth2.Client.get!(client, user_url)
  end
end
