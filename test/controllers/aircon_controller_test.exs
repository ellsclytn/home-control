defmodule Thermio.AirconControllerTest do
  use Thermio.ConnCase

  alias Thermio.Aircon
  @valid_attrs %{fan: 42, h_dir: 42, mode: 42, power: 42, temp: 42, v_dir: 42}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, aircon_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    aircon = Repo.insert! %Aircon{}
    conn = get conn, aircon_path(conn, :show, aircon)
    assert json_response(conn, 200)["data"] == %{"id" => aircon.id,
      "power" => aircon.power,
      "mode" => aircon.mode,
      "fan" => aircon.fan,
      "temp" => aircon.temp,
      "v_dir" => aircon.v_dir,
      "h_dir" => aircon.h_dir}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, aircon_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, aircon_path(conn, :create), aircon: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Aircon, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, aircon_path(conn, :create), aircon: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    aircon = Repo.insert! %Aircon{}
    conn = put conn, aircon_path(conn, :update, aircon), aircon: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Aircon, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    aircon = Repo.insert! %Aircon{}
    conn = put conn, aircon_path(conn, :update, aircon), aircon: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    aircon = Repo.insert! %Aircon{}
    conn = delete conn, aircon_path(conn, :delete, aircon)
    assert response(conn, 204)
    refute Repo.get(Aircon, aircon.id)
  end
end
