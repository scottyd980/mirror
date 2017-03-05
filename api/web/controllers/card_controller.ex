defmodule Mirror.CardController do
  use Mirror.Web, :controller

  alias Mirror.{Card, Organization}

  # def index(conn, _params) do
  #   cards = Repo.all(Card)
  #   render(conn, "index.json", cards: cards)
  # end

  import Logger

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  # TODO: Need to make sure person adding the card is an org admin

  def create(conn, %{"data" => %{"attributes" => attributes, "relationships" => relationships, "type" => "cards"}}) do
    
    organization_id = relationships["organization"]["data"]["id"]
    
    organization = Repo.get_by!(Organization, uuid: organization_id)

    customer_id = organization.billing_customer

    new_fields = %{
      source: attributes["token-id"]
    }

    {:ok, updates} = Stripe.Customers.update customer_id, new_fields

    Logger.warn "#{inspect updates}"

    conn
    |> put_status(:ok)
    # changeset = Card.changeset(%Card{}, card_params)

    # case Repo.insert(changeset) do
    #   {:ok, card} ->
    #     conn
    #     |> put_status(:created)
    #     |> put_resp_header("location", card_path(conn, :show, card))
    #     |> render("show.json", card: card)
    #   {:error, changeset} ->
    #     conn
    #     |> put_status(:unprocessable_entity)
    #     |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    # end
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
end
