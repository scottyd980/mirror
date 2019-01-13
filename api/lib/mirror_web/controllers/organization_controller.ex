defmodule MirrorWeb.OrganizationController do
  use MirrorWeb, :controller

  alias Mirror.Organizations
  alias Mirror.Organizations.Organization

  alias Mirror.Payments

  alias Mirror.Helpers

  action_fallback MirrorWeb.FallbackController

  def create(conn, %{"data" => data}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    organization_params = JaSerializer.Params.to_attributes(data)
    organization_admins = [current_user]
    organization_members = [current_user]

    with {:ok, %Organization{} = organization} <- Organizations.create_organization(organization_params, organization_admins, organization_members)
    do
      conn
      |> put_status(:created)
      |> render("show.json-api", data: organization |> Organization.preload_relationships)
    else
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: changeset)
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: %{})
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    organization = Organizations.get_organization!(id)

    case Helpers.User.user_is_organization_admin?(current_user, organization) do
      true ->
        render(conn, "show.json-api", data: organization |> Organization.preload_relationships)
      _ ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json")
    end
  end

  def update(conn, %{"data" => data}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    update_params = JaSerializer.Params.to_attributes(data)
    organization = Organizations.get_organization!(data["id"])

    organization_params = %{
      name: update_params["name"],
      billing_frequency: update_params["billing_frequency"],
      default_payment_id: get_payment_source(update_params).id
    }

    case Helpers.User.user_is_organization_admin?(current_user, organization) do
      true ->
        with {:ok, %Organization{} = organization} <- Organizations.update_organization(organization, organization_params)
        do
          render(conn, "show.json-api", data: organization |> Organization.preload_relationships)
        else
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: changeset)
        end
      _ ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json-api")
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    organization = Organizations.get_organization!(id)

    case Helpers.User.user_is_organization_admin?(current_user, organization) do
      true ->
        with {:ok, %Organization{}} <- Organizations.delete_organization(organization)
        do
          conn
          |> put_status(:ok)
          |> render("delete.json-api")
        else
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: changeset)
        end
      _ ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json-api")
    end
  end

  defp get_payment_source(update_params) do
    card_id = update_params["default_payment_id"]

    case card_id do
      nil -> %{id: nil}
      _ -> Payments.get_card!(card_id)
    end
  end
end
