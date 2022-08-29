defmodule TictactwoWeb.PageController do
  use TictactwoWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/lobby")
  end
end
