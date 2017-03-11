defmodule Mirror.OrganizationController do
  use Mirror.Web, :controller

  alias Mirror.{Organization, Card}

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  import Logger

  # def index(conn, _params) do
  #   organizations = Repo.all(Organization)
  #   render(conn, "index.json", organizations: organizations)
  # end

  def create(conn, %{"data" => %{"attributes" => attributes, "relationships" => relationships, "type" => "organizations"}}) do

    org_members = [Guardian.Plug.current_resource(conn)]
    org_admins = [Guardian.Plug.current_resource(conn)]
    # organization_member_delegates = attributes["member-delegates"]

    params = %{"attributes" => attributes, "admins" => org_admins, "members" => org_members}

    case Organization.create(params) do
      {:ok, organization} ->
        conn
        |> put_status(:created)
        |> render("show.json", organization: organization)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    end

  end

  def show(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    organization = Repo.get_by!(Organization, uuid: id)
    |> Organization.preload_relationships()
    
    case Enum.member?(organization.members, current_user) || Enum.member?(organization.admins, current_user) do
      true ->
        render(conn, "show.json", organization: organization)
      _ ->
        conn
        |> put_status(404)
        |> render(Mirror.ErrorView, "404.json")
    end
  end

  def update(conn, %{"data" => %{"id" => id, "attributes" => attributes, "relationships" => relationships, "type" => "organizations"}}) do
    current_user = Guardian.Plug.current_resource(conn)
    
    organization = Repo.get_by!(Organization, uuid: id)
    |> Organization.preload_relationships()

    default_payment = Repo.get_by!(Card, card_id: attributes["default-payment"])

    organization_params = %{
      name: attributes["name"], 
      avatar: attributes["avatar"],
      default_payment_id: default_payment.id
    }

    case Enum.member?(organization.members, current_user) || Enum.member?(organization.admins, current_user) do
      true ->
        changeset = Organization.changeset(organization, organization_params)
        case Repo.update(changeset) do
          {:ok, organization} ->
            Stripe.Customers.update(organization.billing_customer, %{default_source: attributes["default-payment"]})
            render(conn, "show.json", organization: organization)
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
        end
      _ ->
        conn
        |> put_status(404)
        |> render(Mirror.ErrorView, "404.json")
    end
  end

  def delete(conn, %{"id" => id}) do
    organization = Repo.get!(Organization, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(organization)

    send_resp(conn, :no_content, "")
  end
end
