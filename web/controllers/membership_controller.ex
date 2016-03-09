defmodule Meetup.MembershipController do
  use Meetup.Web, :controller

  alias Meetup.Membership
  alias Meetup.Member

  plug :scrub_params, "membership" when action in [:create, :update]
  plug :load_members when action in [:new, :create, :edit, :update]

  def index(conn, _params) do
    memberships = Repo.all(Membership)
    render(conn, "index.html", memberships: memberships)
  end

  def new(conn, _params) do
    changeset = Membership.changeset(%Membership{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"membership" => membership_params}) do
    changeset = Membership.changeset(%Membership{}, membership_params)

    case Repo.insert(changeset) do
      {:ok, _membership} ->
        conn
        |> put_flash(:info, "Membership created successfully.")
        |> redirect(to: membership_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    membership = Repo.get!(Membership, id)
    render(conn, "show.html", membership: membership)
  end

  def edit(conn, %{"id" => id}) do
    membership = Repo.get!(Membership, id)
    changeset = Membership.changeset(membership)
    render(conn, "edit.html", membership: membership, changeset: changeset)
  end

  def update(conn, %{"id" => id, "membership" => membership_params}) do
    membership = Repo.get!(Membership, id)
    changeset = Membership.changeset(membership, membership_params)

    case Repo.update(changeset) do
      {:ok, membership} ->
        conn
        |> put_flash(:info, "Membership updated successfully.")
        |> redirect(to: membership_path(conn, :show, membership))
      {:error, changeset} ->
        render(conn, "edit.html", membership: membership, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    membership = Repo.get!(Membership, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(membership)

    conn
    |> put_flash(:info, "Membership deleted successfully.")
    |> redirect(to: membership_path(conn, :index))
  end

  defp load_members(conn, _opts) do
    query = from m in Member, order_by: m.name, select: {m.name, m.id}
    members = Repo.all(query)
    assign(conn, :members, members)
  end
end
