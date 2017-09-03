defmodule Thermio.MessageTest do
  use Thermio.ModelCase

  alias Thermio.Message

  @valid_attrs %{origin: "some content", sent_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, text: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Message.changeset(%Message{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Message.changeset(%Message{}, @invalid_attrs)
    refute changeset.valid?
  end
end
