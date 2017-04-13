defmodule Mirror.OrganizationView do
  use Mirror.Web, :view

  import Logger

  def render("index.json", %{organizations: organizations}) do
    %{data: render_many(organizations, Mirror.OrganizationView, "organization.json")}
  end

  def render("show.json", %{organization: organization}) do
    %{data: render_one(organization, Mirror.OrganizationView, "organization.json")}
  end

  def render("organization.json", %{organization: organization}) do
    case is_nil(organization.default_payment) do
      true ->
        default_card = nil
      _ ->
        default_card = organization.default_payment
    end

    %{
    	"type": "organization",
    	"id": organization.uuid,
    	"attributes": %{
        "name": organization.name,
        "avatar": organization.avatar,
        "billing-status": organization.billing_status
    	},
      "relationships": %{
        "admins": %{
          "links": %{
            "self": "/api/users/"
          },
          "data": render_many(organization.admins, Mirror.UserView, "relationship.json", as: :user)
      	},
        "members": %{
          "links": %{
            "self": "/api/users/"
          },
          "data": render_many(organization.members, Mirror.UserView, "relationship.json", as: :user)
        },
        "teams": %{
          "links": %{
            "self": "/api/teams/"
          },
          "data": render_many(organization.teams, Mirror.TeamView, "relationship.json", as: :team)
      	},
        "cards": %{
          "links": %{
            "self": "/api/cards/"
          },
          "data": render_many(organization.cards, Mirror.CardView, "relationship.json", as: :card)
        },
        "default-payment": %{
          "links": %{
            "self": "/api/cards/"
          },
          "data": render_one(default_card, Mirror.CardView, "relationship.json", as: :card)
        }
      }
    }
  end

  def render("relationship.json", %{organization: organization}) do
    %{
      "type": "organization",
      "id": organization.uuid
    }
  end
end
