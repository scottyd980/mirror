defmodule Mirror.CardController do
  use Mirror.Web, :controller

  alias Mirror.{Card, Organization, UserHelper, Billing}

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
  # TODO: Make this a transaction?

  def create(conn, %{"data" => %{"attributes" => attributes, "relationships" => relationships, "type" => "cards"}}) do
    
    organization_id = relationships["organization"]["data"]["id"]
    organization = Repo.get_by!(Organization, uuid: organization_id)
    current_user = Guardian.Plug.current_resource(conn)

    case UserHelper.user_is_organization_admin?(current_user, organization) do
      true ->
        params = %{"attributes" => attributes, "organization" => organization}
        
        make_default = true

        case create_card(params) do
          {:ok, card} ->

            case make_default do
              true ->
                case create_default_card(params) do
                  {:ok, updated_org} ->
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

  defp create_card(params) do
    Repo.transaction fn ->
      with {:ok, card} <- insert_card(params),
           {:ok, cust_card} <- insert_customer_card(params) do
             card
             |> Card.preload_relationships()
      else
        {:error, changeset} ->
          Repo.rollback changeset
      end
    end
  end

  defp insert_card(params) do
    %Card{}
    |> Card.changeset(%{
          brand: params["attributes"]["brand"],
          last4: params["attributes"]["last4"],
          exp_month: params["attributes"]["exp-month"],
          exp_year: params["attributes"]["exp-year"],
          token_id: params["attributes"]["token-id"],
          card_id: params["attributes"]["card-id"],
          organization_id: params["organization"].id,
          zip_code: params["attributes"]["zip-code"]
      })
    |> Repo.insert
  end

  defp insert_customer_card(params) do
    cust_card = %{
      source: params["attributes"]["token-id"]
    }

    Stripe.Cards.create(:customer, params["organization"].billing_customer, cust_card)
  end

  defp create_default_card(params) do
    Repo.transaction fn ->
      with {:ok, updated_org} <- update_default_card(params),
           {:ok, updated_cust} <- Billing.update_default_payment(params["organization"].billing_customer, params["attributes"]["card-id"])do
             updated_org
             |> Organization.preload_relationships()
      else
        {:error, changeset} ->
          Repo.rollback changeset
      end
    end
  end

  defp update_default_card(params) do
    card = Repo.get_by!(Card, card_id: params["attributes"]["card-id"])

    Organization.changeset(params["organization"], %{default_payment_id: card.id})
    |> Repo.update
  end
  
  def show(conn, %{"id" => id}) do
    card = Repo.get_by!(Card, card_id: id)
    |> Card.preload_relationships()
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
    card = Repo.get_by!(Card, card_id: id)
    |> Card.preload_relationships()

    organization = card.organization

    case UserHelper.user_is_organization_admin?(current_user, organization) do
      true ->
        Repo.transaction fn ->
          with removed_card <- remove_card(card),
               {:ok, removed_customer_card} <- remove_customer_card(card, organization)
          do
            conn
            |> render("delete.json", card: card)
          else
            {:error, changeset} ->
              Repo.rollback changeset
          end
        end
      _ ->
        use_error_view(conn, 401, %{})
    end
  end

  defp remove_card(card) do
    Repo.delete!(card)
  end

  defp remove_customer_card(card, organization) do
    Stripe.Cards.delete(:customer, organization.billing_customer, card.card_id)
  end

  defp use_error_view(conn, status, changeset) do
    conn
    |> put_status(status)
    |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
  end
end
