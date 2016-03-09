defmodule Meetup.TopicControllerTest do
  use Meetup.ConnCase

  alias Meetup.Topic
  @valid_attrs %{name: "some content", remote_id: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, topic_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing topics"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, topic_path(conn, :new)
    assert html_response(conn, 200) =~ "New topic"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, topic_path(conn, :create), topic: @valid_attrs
    assert redirected_to(conn) == topic_path(conn, :index)
    assert Repo.get_by(Topic, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, topic_path(conn, :create), topic: @invalid_attrs
    assert html_response(conn, 200) =~ "New topic"
  end

  test "shows chosen resource", %{conn: conn} do
    topic = Repo.insert! %Topic{}
    conn = get conn, topic_path(conn, :show, topic)
    assert html_response(conn, 200) =~ "Show topic"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, topic_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    topic = Repo.insert! %Topic{}
    conn = get conn, topic_path(conn, :edit, topic)
    assert html_response(conn, 200) =~ "Edit topic"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    topic = Repo.insert! %Topic{}
    conn = put conn, topic_path(conn, :update, topic), topic: @valid_attrs
    assert redirected_to(conn) == topic_path(conn, :show, topic)
    assert Repo.get_by(Topic, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    topic = Repo.insert! %Topic{}
    conn = put conn, topic_path(conn, :update, topic), topic: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit topic"
  end

  test "deletes chosen resource", %{conn: conn} do
    topic = Repo.insert! %Topic{}
    conn = delete conn, topic_path(conn, :delete, topic)
    assert redirected_to(conn) == topic_path(conn, :index)
    refute Repo.get(Topic, topic.id)
  end
end
