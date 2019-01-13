defmodule MirrorWeb.OrganizationSerializer do
  use JaSerializer

  def id(organization, _conn), do: organization.uuid
  def type, do: "organization"
end