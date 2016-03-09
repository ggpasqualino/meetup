defmodule Meetup.MemberController do
  use Meetup.Web, :controller

  alias Meetup.Member

  plug :scrub_params, "member" when action in [:create, :update]

  def index(conn, _params) do
    members = Repo.all(Member)
    render(conn, "index.html", members: members)
  end

  def new(conn, _params) do
    changeset = Member.changeset(%Member{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"member" => member_params}) do
    changeset = Member.changeset(%Member{}, member_params)

    case Repo.insert(changeset) do
      {:ok, _member} ->
        conn
        |> put_flash(:info, "Member created successfully.")
        |> redirect(to: member_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    member = Repo.get!(Member, id)
    render(conn, "show.html", member: member)
  end

  def edit(conn, %{"id" => id}) do
    member = Repo.get!(Member, id)
    changeset = Member.changeset(member)
    render(conn, "edit.html", member: member, changeset: changeset)
  end

  def update(conn, %{"id" => id, "member" => member_params}) do
    member = Repo.get!(Member, id)
    changeset = Member.changeset(member, member_params)

    case Repo.update(changeset) do
      {:ok, member} ->
        conn
        |> put_flash(:info, "Member updated successfully.")
        |> redirect(to: member_path(conn, :show, member))
      {:error, changeset} ->
        render(conn, "edit.html", member: member, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    member = Repo.get!(Member, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(member)

    conn
    |> put_flash(:info, "Member deleted successfully.")
    |> redirect(to: member_path(conn, :index))
  end
end
