defmodule Thermio.SoilControllerTest do
  use Thermio.ConnCase

  alias Thermio.Soil
  @valid_attrs %{moisture: 42}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, soil_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    soil = Repo.insert! %Soil{}
    conn = get conn, soil_path(conn, :show, soil)
    assert json_response(conn, 200)["data"] == %{"id" => soil.id,
      "moisture" => soil.moisture}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, soil_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, soil_path(conn, :create), soil: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Soil, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, soil_path(conn, :create), soil: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    soil = Repo.insert! %Soil{}
    conn = put conn, soil_path(conn, :update, soil), soil: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Soil, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    soil = Repo.insert! %Soil{}
    conn = put conn, soil_path(conn, :update, soil), soil: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    soil = Repo.insert! %Soil{}
    conn = delete conn, soil_path(conn, :delete, soil)
    assert response(conn, 204)
    refute Repo.get(Soil, soil.id)
  end
end
