defmodule MirrorWeb.SubmissionControllerTest do
  use MirrorWeb.ConnCase

  alias Mirror.Retrospectives
  alias Mirror.Retrospectives.Submission

  @create_attrs %{feedback: true, score: true}
  @update_attrs %{feedback: false, score: false}
  @invalid_attrs %{feedback: nil, score: nil}

  def fixture(:submission) do
    {:ok, submission} = Retrospectives.create_submission(@create_attrs)
    submission
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all submissions", %{conn: conn} do
      conn = get conn, submission_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create submission" do
    test "renders submission when data is valid", %{conn: conn} do
      conn = post conn, submission_path(conn, :create), submission: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, submission_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "feedback" => true,
        "score" => true}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, submission_path(conn, :create), submission: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update submission" do
    setup [:create_submission]

    test "renders submission when data is valid", %{conn: conn, submission: %Submission{id: id} = submission} do
      conn = put conn, submission_path(conn, :update, submission), submission: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, submission_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "feedback" => false,
        "score" => false}
    end

    test "renders errors when data is invalid", %{conn: conn, submission: submission} do
      conn = put conn, submission_path(conn, :update, submission), submission: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete submission" do
    setup [:create_submission]

    test "deletes chosen submission", %{conn: conn, submission: submission} do
      conn = delete conn, submission_path(conn, :delete, submission)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, submission_path(conn, :show, submission)
      end
    end
  end

  defp create_submission(_) do
    submission = fixture(:submission)
    {:ok, submission: submission}
  end
end
