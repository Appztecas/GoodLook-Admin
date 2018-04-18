defmodule AuthExWeb.PageController do
  use AuthExWeb, :controller
  alias AuthEx.Auth
  alias AuthEx.Auth.User
  alias AuthEx.Auth.Guardian

  def index(conn, _params) do
    changeset = Auth.change_user(%User{})
    maybe_user = Guardian.Plug.current_resource(conn)
    if maybe_user != nil do
      redirect(conn, to: page_path(conn, :home))
    else
      message = "No one is logged in"
      conn
      |> put_flash(:info, message)
      |> render("index.html", changeset: changeset, action: page_path(conn, :login), maybe_user: maybe_user)
    end
  end

  def login(conn, %{"user" => %{"username" => username, "password" => password}}) do
    Auth.authenticate_user(username, password)
    |> login_reply(conn)
  end

  defp login_reply({:error, error}, conn) do
    conn
    |> put_flash(:error, error)
    |> redirect(to: "/")
  end
  defp login_reply({:ok, user}, conn) do
    conn
    |> put_flash(:success, "Welcome back!")
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: "/home")
  end

  def logout(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> redirect(to: page_path(conn, :login))
  end

  def home(conn, _params) do
    maybe_user = Guardian.Plug.current_resource(conn)
    IO.inspect maybe_user
    render(conn, "secret.html", maybe_user: maybe_user)
  end
end
