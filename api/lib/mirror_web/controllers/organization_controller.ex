defmodule MirrorWeb.OrganizationController do
  use MirrorWeb, :controller

  alias Mirror.Organizations
  alias Mirror.Organizations.Organization

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

  # TODO: WORK - BILLING
  # def update(conn, %{"id" => id, "organization" => organization_params}) do
  #   organization = Organizations.get_organization!(id)

  #   with {:ok, %Organization{} = organization} <- Organizations.update_organization(organization, organization_params) do
  #     render(conn, "show.json", organization: organization)
  #   end
  # end

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
        |> render(MirrorWeb.ErrorView, "404.json")
    end
  end
end
