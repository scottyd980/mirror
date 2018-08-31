defmodule MirrorWeb.PaymentCardController do
  use MirrorWeb, :controller

  alias Mirror.{Payments, Organizations}
  alias Mirror.Payments.Card

  alias Mirror.Helpers

  action_fallback MirrorWeb.FallbackController

  def index(conn, %{"filter" => filter}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    organization = Organizations.get_organization!(filter["organization"])

    case Helpers.User.user_is_organization_admin?(current_user, organization) do
      true ->
        cards = Payments.list_cards(organization)
        render(conn, "show.json-api", data: cards |> Card.preload_relationships)
      _ ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json-api")
    end
  end

  def index(conn, _) do
    render(conn, "show.json-api", data: [])
  end

  def create(conn, %{"data" => data}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)
    card_params = JaSerializer.Params.to_attributes(data)

    organization = Organizations.get_organization!(card_params["organization_id"])

    card_params = Map.put(card_params, "organization_id", organization.id)
    card_params = Map.put(card_params, "customer", organization.billing_customer)

    make_default = is_nil(organization.default_payment_id)

    case Helpers.User.user_is_organization_admin?(current_user, organization) do
      true ->
        with {:ok, %Card{} = card} <- Payments.create_card(card_params, true) 
        do
          conn
          |> put_status(:created)
          |> render("show.json-api", data: card |> Card.preload_relationships)
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

  # def show(conn, %{"id" => id}) do
  #   card = Payments.get_card!(id)
  #   render(conn, "show.json", card: card)
  # end

  # def update(conn, %{"id" => id, "card" => card_params}) do
  #   card = Payments.get_card!(id)

  #   with {:ok, %Card{} = card} <- Payments.update_card(card, card_params) do
  #     render(conn, "show.json", card: card)
  #   end
  # end

  def delete(conn, %{"id" => id}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)
    
    card = Payments.get_card!(id)
    |> Card.preload_relationships

    case Helpers.User.user_is_organization_admin?(current_user, card.organization) do
      true ->
        with {:ok, %Card{}} <- Payments.delete_card(card) 
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
end
