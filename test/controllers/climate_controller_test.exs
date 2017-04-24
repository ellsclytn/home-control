defmodule Thermio.ClimateControllerTest do
  use Thermio.ConnCase

  alias Thermio.Climate
  @valid_attrs %{heat_index: "120.5", humidity: "120.5", temperature: "120.5"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, climate_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    climate = Repo.insert! %Climate{}
    conn = get conn, climate_path(conn, :show, climate)
    assert json_response(conn, 200)["data"] == %{"id" => climate.id,
      "heat_index" => climate.heat_index,
      "humidity" => climate.humidity,
      "temperature" => climate.temperature}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, climate_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, climate_path(conn, :create), climate: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Climate, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, climate_path(conn, :create), climate: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    climate = Repo.insert! %Climate{}
    conn = put conn, climate_path(conn, :update, climate), climate: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Climate, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    climate = Repo.insert! %Climate{}
    conn = put conn, climate_path(conn, :update, climate), climate: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    climate = Repo.insert! %Climate{}
    conn = delete conn, climate_path(conn, :delete, climate)
    assert response(conn, 204)
    refute Repo.get(Climate, climate.id)
  end
end
