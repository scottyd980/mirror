defmodule Mirror.TeamsTest do
  use Mirror.DataCase

  alias Mirror.Teams

  describe "teams" do
    alias Mirror.Teams.Team

    @valid_attrs %{avatar: "some avatar", is_anonymous: true, name: "some name", uuid: "some uuid"}
    @update_attrs %{avatar: "some updated avatar", is_anonymous: false, name: "some updated name", uuid: "some updated uuid"}
    @invalid_attrs %{avatar: nil, is_anonymous: nil, name: nil, uuid: nil}

    def team_fixture(attrs \\ %{}) do
      {:ok, team} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Teams.create_team()

      team
    end

    test "list_teams/0 returns all teams" do
      team = team_fixture()
      assert Teams.list_teams() == [team]
    end

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Teams.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      assert {:ok, %Team{} = team} = Teams.create_team(@valid_attrs)
      assert team.avatar == "some avatar"
      assert team.is_anonymous == true
      assert team.name == "some name"
      assert team.uuid == "some uuid"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      assert {:ok, team} = Teams.update_team(team, @update_attrs)
      assert %Team{} = team
      assert team.avatar == "some updated avatar"
      assert team.is_anonymous == false
      assert team.name == "some updated name"
      assert team.uuid == "some updated uuid"
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = Teams.update_team(team, @invalid_attrs)
      assert team == Teams.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %Team{}} = Teams.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = Teams.change_team(team)
    end
  end

  describe "members" do
    alias Mirror.Teams.Member

    @valid_attrs %{team_id: 42, user_id: 42}
    @update_attrs %{team_id: 43, user_id: 43}
    @invalid_attrs %{team_id: nil, user_id: nil}

    def member_fixture(attrs \\ %{}) do
      {:ok, member} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Teams.create_member()

      member
    end

    test "list_members/0 returns all members" do
      member = member_fixture()
      assert Teams.list_members() == [member]
    end

    test "get_member!/1 returns the member with given id" do
      member = member_fixture()
      assert Teams.get_member!(member.id) == member
    end

    test "create_member/1 with valid data creates a member" do
      assert {:ok, %Member{} = member} = Teams.create_member(@valid_attrs)
      assert member.team_id == 42
      assert member.user_id == 42
    end

    test "create_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_member(@invalid_attrs)
    end

    test "update_member/2 with valid data updates the member" do
      member = member_fixture()
      assert {:ok, member} = Teams.update_member(member, @update_attrs)
      assert %Member{} = member
      assert member.team_id == 43
      assert member.user_id == 43
    end

    test "update_member/2 with invalid data returns error changeset" do
      member = member_fixture()
      assert {:error, %Ecto.Changeset{}} = Teams.update_member(member, @invalid_attrs)
      assert member == Teams.get_member!(member.id)
    end

    test "delete_member/1 deletes the member" do
      member = member_fixture()
      assert {:ok, %Member{}} = Teams.delete_member(member)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_member!(member.id) end
    end

    test "change_member/1 returns a member changeset" do
      member = member_fixture()
      assert %Ecto.Changeset{} = Teams.change_member(member)
    end
  end

  describe "admins" do
    alias Mirror.Teams.Admin

    @valid_attrs %{team_id: 42, user_id: 42}
    @update_attrs %{team_id: 43, user_id: 43}
    @invalid_attrs %{team_id: nil, user_id: nil}

    def admin_fixture(attrs \\ %{}) do
      {:ok, admin} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Teams.create_admin()

      admin
    end

    test "list_admins/0 returns all admins" do
      admin = admin_fixture()
      assert Teams.list_admins() == [admin]
    end

    test "get_admin!/1 returns the admin with given id" do
      admin = admin_fixture()
      assert Teams.get_admin!(admin.id) == admin
    end

    test "create_admin/1 with valid data creates a admin" do
      assert {:ok, %Admin{} = admin} = Teams.create_admin(@valid_attrs)
      assert admin.team_id == 42
      assert admin.user_id == 42
    end

    test "create_admin/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_admin(@invalid_attrs)
    end

    test "update_admin/2 with valid data updates the admin" do
      admin = admin_fixture()
      assert {:ok, admin} = Teams.update_admin(admin, @update_attrs)
      assert %Admin{} = admin
      assert admin.team_id == 43
      assert admin.user_id == 43
    end

    test "update_admin/2 with invalid data returns error changeset" do
      admin = admin_fixture()
      assert {:error, %Ecto.Changeset{}} = Teams.update_admin(admin, @invalid_attrs)
      assert admin == Teams.get_admin!(admin.id)
    end

    test "delete_admin/1 deletes the admin" do
      admin = admin_fixture()
      assert {:ok, %Admin{}} = Teams.delete_admin(admin)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_admin!(admin.id) end
    end

    test "change_admin/1 returns a admin changeset" do
      admin = admin_fixture()
      assert %Ecto.Changeset{} = Teams.change_admin(admin)
    end
  end

  describe "member_delegates" do
    alias Mirror.Teams.MemberDelegate

    @valid_attrs %{access_code: "some access_code", email: "some email", is_accessed: true}
    @update_attrs %{access_code: "some updated access_code", email: "some updated email", is_accessed: false}
    @invalid_attrs %{access_code: nil, email: nil, is_accessed: nil}

    def member_delegate_fixture(attrs \\ %{}) do
      {:ok, member_delegate} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Teams.create_member_delegate()

      member_delegate
    end

    test "list_member_delegates/0 returns all member_delegates" do
      member_delegate = member_delegate_fixture()
      assert Teams.list_member_delegates() == [member_delegate]
    end

    test "get_member_delegate!/1 returns the member_delegate with given id" do
      member_delegate = member_delegate_fixture()
      assert Teams.get_member_delegate!(member_delegate.id) == member_delegate
    end

    test "create_member_delegate/1 with valid data creates a member_delegate" do
      assert {:ok, %MemberDelegate{} = member_delegate} = Teams.create_member_delegate(@valid_attrs)
      assert member_delegate.access_code == "some access_code"
      assert member_delegate.email == "some email"
      assert member_delegate.is_accessed == true
    end

    test "create_member_delegate/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_member_delegate(@invalid_attrs)
    end

    test "update_member_delegate/2 with valid data updates the member_delegate" do
      member_delegate = member_delegate_fixture()
      assert {:ok, member_delegate} = Teams.update_member_delegate(member_delegate, @update_attrs)
      assert %MemberDelegate{} = member_delegate
      assert member_delegate.access_code == "some updated access_code"
      assert member_delegate.email == "some updated email"
      assert member_delegate.is_accessed == false
    end

    test "update_member_delegate/2 with invalid data returns error changeset" do
      member_delegate = member_delegate_fixture()
      assert {:error, %Ecto.Changeset{}} = Teams.update_member_delegate(member_delegate, @invalid_attrs)
      assert member_delegate == Teams.get_member_delegate!(member_delegate.id)
    end

    test "delete_member_delegate/1 deletes the member_delegate" do
      member_delegate = member_delegate_fixture()
      assert {:ok, %MemberDelegate{}} = Teams.delete_member_delegate(member_delegate)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_member_delegate!(member_delegate.id) end
    end

    test "change_member_delegate/1 returns a member_delegate changeset" do
      member_delegate = member_delegate_fixture()
      assert %Ecto.Changeset{} = Teams.change_member_delegate(member_delegate)
    end
  end
end
