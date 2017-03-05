defmodule Mirror.CardController do
  use Mirror.Web, :controller

  alias Mirror.{Card, Organization, UserHelper}

  import Logger

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  # TODO: Better error handling...

  def index(conn, params) do
    current_user = Guardian.Plug.current_resource(conn)

    organization = Repo.get_by!(Organization, uuid: params["filter"]["organization"])
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

  # TODO: Need better error handling
  # TODO: Make this a transaction?

  def create(conn, %{"data" => %{"attributes" => attributes, "relationships" => relationships, "type" => "cards"}}) do
    
    organization_id = relationships["organization"]["data"]["id"]
    organization = Repo.get_by!(Organization, uuid: organization_id)
    current_user = Guardian.Plug.current_resource(conn)

    case UserHelper.user_is_organization_admin?(current_user, organization) do
      true ->
        customer_id = organization.billing_customer
        cust_card = %{
          source: attributes["token-id"]
        }
        
        changeset = Card.changeset %Card{}, %{
            brand: attributes["brand"],
            last4: attributes["last4"],
            exp_month: attributes["exp-month"],
            exp_year: attributes["exp-year"],
            token_id: attributes["token-id"],
            card_id: attributes["card-id"],
            organization_id: organization.id
        }

        case Repo.insert changeset do
            {:ok, card} ->
              case Stripe.Cards.create(:customer, customer_id, cust_card) do
                {:ok, _} ->

                  # Only do this if we want to default the card, then we'll have to listen to default updates from stripe
                  # Stripe.Customers.update(customer_id, %{default_source: attributes["card-id"]})

                  card = card
                  |> Card.preload_relationships

                  conn
                  |> put_status(:created)
                  |> render("show.json", card: card)
                  
                {:error, error} ->
                  use_error_view(conn, :unprocessable_entity, %{})
              end
            {:error, changeset} ->
                use_error_view(conn, 422, changeset)
        end
      _ ->
        use_error_view(conn, 401, %{})
    end
  end

  # def show(conn, %{"id" => id}) do
  #   card = Repo.get!(Card, id)
  #   render(conn, "show.json", card: card)
  # end

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

  # def delete(conn, %{"id" => id}) do
  #   card = Repo.get!(Card, id)

  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(card)

  #   send_resp(conn, :no_content, "")
  # end

  defp use_error_view(conn, status, changeset) do
    conn
    |> put_status(status)
    |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
  end
end
