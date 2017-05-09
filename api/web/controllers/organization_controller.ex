defmodule Mirror.OrganizationController do
  use Mirror.Web, :controller

  alias Mirror.{Organization, Card, Billing, UserHelper, OrgHelper, Helpers}

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  import Logger

  # def index(conn, _params) do
  #   organizations = Repo.all(Organization)
  #   render(conn, "index.json", organizations: organizations)
  # end

  def create(conn, %{"data" => data}) do
    data = Helpers.atomic_map(data)

    org_members = [Guardian.Plug.current_resource(conn)]
    org_admins = [Guardian.Plug.current_resource(conn)]

    params = %{
      attributes: data.attributes,
      admins: org_admins,
      members: org_members
    }

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
    organization = Organization.get(id)
    
    case UserHelper.user_is_organization_admin?(current_user, organization) do
      true ->
        render(conn, "show.json", organization: organization)
      _ ->
        conn
        |> put_status(404)
        |> render(Mirror.ErrorView, "404.json")
    end
  end

  def update(conn, %{"data" => data}) do
    current_user = Guardian.Plug.current_resource(conn)
    data = Helpers.atomic_map(data)
    organization = Organization.get(data.id)

    card_id = case data.relationships.default_payment.data do
      nil -> nil
      data -> data.id
    end

    card = case card_id do
      nil -> %{id: nil}
      _ -> Repo.get_by!(Card, card_id: card_id)
    end

    organization_params = %{
      name: data.attributes.name, 
      avatar: data.attributes.avatar,
      billing_frequency: data.attributes.billing_frequency || "none",
      default_payment_id: card.id
    }

    billing_params = %{
      default_payment: card_id
    }

    case UserHelper.user_is_organization_admin?(current_user, organization) && OrgHelper.card_on_file?(organization, card_id) do
      true ->
        case Organization.update(organization, organization_params, billing_params) do
          {:ok, updated_org} ->
            conn
            |> put_status(:ok)
            |> render("show.json", organization: updated_org)
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
