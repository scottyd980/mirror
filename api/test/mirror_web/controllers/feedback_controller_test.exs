defmodule MirrorWeb.FeedbackControllerTest do
  use MirrorWeb.ConnCase

  alias Mirror.Retrospectives
  alias Mirror.Retrospectives.Feedback

  @create_attrs %{category: "some category", message: "some message", state: 42}
  @update_attrs %{category: "some updated category", message: "some updated message", state: 43}
  @invalid_attrs %{category: nil, message: nil, state: nil}

  def fixture(:feedback) do
    {:ok, feedback} = Retrospectives.create_feedback(@create_attrs)
    feedback
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all feedbacks", %{conn: conn} do
      conn = get conn, feedback_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create feedback" do
    test "renders feedback when data is valid", %{conn: conn} do
      conn = post conn, feedback_path(conn, :create), feedback: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, feedback_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "category" => "some category",
        "message" => "some message",
        "state" => 42}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, feedback_path(conn, :create), feedback: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update feedback" do
    setup [:create_feedback]

    test "renders feedback when data is valid", %{conn: conn, feedback: %Feedback{id: id} = feedback} do
      conn = put conn, feedback_path(conn, :update, feedback), feedback: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, feedback_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "category" => "some updated category",
        "message" => "some updated message",
        "state" => 43}
    end

    test "renders errors when data is invalid", %{conn: conn, feedback: feedback} do
      conn = put conn, feedback_path(conn, :update, feedback), feedback: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete feedback" do
    setup [:create_feedback]

    test "deletes chosen feedback", %{conn: conn, feedback: feedback} do
      conn = delete conn, feedback_path(conn, :delete, feedback)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, feedback_path(conn, :show, feedback)
      end
    end
  end

  defp create_feedback(_) do
    feedback = fixture(:feedback)
    {:ok, feedback: feedback}
  end
end
