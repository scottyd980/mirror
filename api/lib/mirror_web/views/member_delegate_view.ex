defmodule MirrorWeb.MemberDelegateView do
  use MirrorWeb, :view
  alias MirrorWeb.MemberDelegateView

  def render("index.json", %{member_delegates: member_delegates}) do
    %{data: render_many(member_delegates, MemberDelegateView, "member_delegate.json")}
  end

  def render("show.json-api", _) do
    %{}
  end

  def render("show.json", %{member_delegate: member_delegate}) do
    %{data: render_one(member_delegate, MemberDelegateView, "member_delegate.json")}
  end

  def render("member_delegate.json", %{member_delegate: member_delegate}) do
    %{id: member_delegate.id,
      email: member_delegate.email,
      access_code: member_delegate.access_code,
      is_accessed: member_delegate.is_accessed}
  end
end
