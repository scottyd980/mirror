defmodule Mirror.CardController do
  use Mirror.Web, :controller

  alias Mirror.{Card, Organization, UserHelper, Billing, Helpers}

  import Logger

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  # TODO: Better error handling...

  def index(conn, %{"filter" => filter}) do
    current_user = Guardian.Plug.current_resource(conn)

    organization = Repo.get_by!(Organization, uuid: filter["organization"])
    customer_id = organization.billing_customer

    case UserHelper.user_is_organization_admin?(current_user, organization) do
     true ->
        query = from r in Card,
                where: r.organization_id == ^organization.id
        cards = Repo.all(query)
        |> Card.preload_relationships()
        render(conn, "index.json", cards: cards)
      _ ->
        use_error_view(conn, 401, %{})
    end
  end

  def index(conn, _) do
    render(conn, "index.json", cards: [])
  end

  # TODO: Need better error handling

  def create(conn, %{"data" => data}) do
    current_user = Guardian.Plug.current_resource(conn)
    data = Helpers.atomic_map(data)
    organization_id = data.relationships.organization.data.id
    organization = Repo.get_by!(Organization, uuid: organization_id)

    card_params = %{
      brand: data.attributes.brand, 
      last4: data.attributes.last4,
      exp_month: data.attributes.exp_month,
      exp_year: data.attributes.exp_year,
      token_id: data.attributes.token_id,
      card_id: data.attributes.card_id,
      zip_code: data.attributes.zip_code,
      organization_id: organization.id,
      customer: organization.billing_customer
    }
    
    make_default = true

    case UserHelper.user_is_organization_admin?(current_user, organization) do
      true ->
        case Card.create(card_params) do
          {:ok, card} ->
            case make_default do
              true ->
                case Organization.set_default_payment(card, organization) do
                  {:ok, updated_org} ->
                    Billing.build_subscriptions(updated_org) 
                    
                    conn
                    |> put_status(:created)
                    |> render("show.json", card: card)
                  {:error, changeset} ->
                    conn
                    |> put_status(:unprocessable_entity)
                    |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
                end
              false ->
                conn
                |> put_status(:created)
                |> render("show.json", card: card)
            end
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
        end
      _ ->
        use_error_view(conn, 401, %{})
    end
  end
  
  def show(conn, %{"id" => id}) do
    card = Card.get(id)
    render(conn, "show.json", card: card)
  end

  # def update(conn, %{"id" => id, "card" => card_params}) do
  #   card = Repo.get!(Card, id)
  #   changeset = Card.changeset(card, card_params)

  #   case Repo.update(changeset) do
  #     {:ok, card} ->
  #       render(conn, "show.json", card: card)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end

  def delete(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    card = Card.get(id)

    organization = card.organization

    case UserHelper.user_is_organization_admin?(current_user, organization) do
      true ->
        case Card.delete(card) do
          {:ok, removed_card} ->
            conn
            |> render("delete.json", card: card)
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
        end
      _ ->
        use_error_view(conn, 401, %{})
    end
  end

  defp use_error_view(conn, status, changeset) do
    conn
    |> put_status(status)
    |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
  end
end
