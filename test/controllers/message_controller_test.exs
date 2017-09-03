defmodule Thermio.MessageControllerTest do
  use Thermio.ConnCase

  alias Thermio.Message
  @valid_attrs %{origin: "some content", sent_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, text: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, message_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    message = Repo.insert! %Message{}
    conn = get conn, message_path(conn, :show, message)
    assert json_response(conn, 200)["data"] == %{"id" => message.id,
      "text" => message.text,
      "sent_at" => message.sent_at,
      "origin" => message.origin}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, message_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, message_path(conn, :create), message: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Message, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, message_path(conn, :create), message: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    message = Repo.insert! %Message{}
    conn = put conn, message_path(conn, :update, message), message: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Message, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    message = Repo.insert! %Message{}
    conn = put conn, message_path(conn, :update, message), message: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    message = Repo.insert! %Message{}
    conn = delete conn, message_path(conn, :delete, message)
    assert response(conn, 204)
    refute Repo.get(Message, message.id)
  end
end
