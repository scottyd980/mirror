defmodule Mirror.CardController do
  use Mirror.Web, :controller

  alias Mirror.{Card, Organization, UserHelper}

  import Logger

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  def index(conn, params) do
    current_user = Guardian.Plug.current_resource(conn)

    organization = Repo.get_by!(Organization, uuid: params["filter"]["organization"])
    customer_id = organization.billing_customer

    case UserHelper.user_is_organization_admin?(current_user, organization) do
     true ->
        case Stripe.Cards.all(:customer, customer_id) do
          {:ok, cards} ->
            cards = Enum.map(cards, fn(card) -> 
              Map.put(card, :organization, organization)
            end)
            render(conn, "index.json", cards: cards)
          {:error, _} ->
            use_error_view(conn, :unprocessable_entity, %{})
        end
      _ ->
        use_error_view(conn, 401, %{})
    end
  end

  # TODO: Need better error handling

  def create(conn, %{"data" => %{"attributes" => attributes, "relationships" => relationships, "type" => "cards"}}) do
    
    organization_id = relationships["organization"]["data"]["id"]
    organization = Repo.get_by!(Organization, uuid: organization_id)
    current_user = Guardian.Plug.current_resource(conn)

    case UserHelper.user_is_organization_admin?(current_user, organization) do
      true ->
        customer_id = organization.billing_customer
        card = %{
          source: attributes["token-id"],
          metadata: %{
            added: DateTime.to_date(DateTime.utc_now())
          }
        }

        case Stripe.Cards.create(:customer, customer_id, card) do
          {:ok, new_card} ->
            Logger.warn "#{inspect new_card}"
            new_card = Map.put(new_card, :organization, organization)
            render(conn, "show.json", card: new_card)
          {:error, _} ->
            use_error_view(conn, :unprocessable_entity, %{})
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
