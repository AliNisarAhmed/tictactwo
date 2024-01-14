defmodule TictactwoWeb.PageController do
  use TictactwoWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: "/lobby")
  end
end
