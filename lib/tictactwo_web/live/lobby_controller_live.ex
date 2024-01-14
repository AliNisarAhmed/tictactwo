defmodule TictactwoWeb.LobbyControllerLive do
  use TictactwoWeb, :live_view

  use Tictactwo.Types

  alias TictactwoWeb.Components.Button
  alias Tictactwo.{Presence, Games, CurrentGames, Tables}
  import PetalComponents.{Tabs, Card, Table, Badge}

  # General lobby events like chats, presence tracking
  @lobby_topic "rooms:lobby"

  # Used by each player in combination with their IDs to receive personal events
  @events_topic "event_bus:"

  # Used for broadcasting events like table created, table deleted
  @tables_topic "tables_topic"

  def mount(_params, session, socket) do
    send(self(), :after_join)

    {:ok,
     assign(socket,
       loading: true,
       current_user: session["current_user"],
       users: %{},
       challenges: [],
       current_games_count: 0,
       current_games: [],
       tab: "one",
       tables: []
     )}
  end

  ## ---- HANDLE EVENTS ----

  # when a user clicks "challenge user" button
  def handle_event("challenge-user", %{"userid" => userid}, socket) do
    users =
      socket.assigns.users
      |> Map.update!(userid, fn prev ->
        prev
        |> Map.update!(:status, &toggle_status/1)
      end)

    TictactwoWeb.Endpoint.broadcast(@events_topic <> userid, "challenge-received", %{
      userid: userid,
      challenger: socket.assigns.current_user
    })

    {:noreply, assign(socket, users: users)}
  end

  # when a user accepts a challenge
  def handle_event(
        "accept-challenge",
        %{"challenger-username" => challenger_username, "challenger-id" => challenger_id},
        socket
      ) do
    game_slug = Games.new_game(:blue, socket.assigns.current_user.username, challenger_username)

    TictactwoWeb.Endpoint.broadcast(@events_topic <> challenger_id, "challenge-accepted", %{
      userid: socket.assigns.current_user.id,
      game_slug: game_slug
    })

    {:noreply, socket}
  end

  # when a user rejects a challenge
  def handle_event(
        "reject-challenge",
        %{"challenger-username" => _challenger_username, "challenger-id" => challenger_id},
        socket
      ) do
    users =
      socket.assigns.users
      |> Map.update!(challenger_id, fn prev ->
        prev
        |> Map.update!(:status, &toggle_status/1)
      end)

    challenges =
      socket.assigns.challenges
      |> Enum.filter(&(&1.id != challenger_id))

    TictactwoWeb.Endpoint.broadcast(@events_topic <> challenger_id, "challenge-rejected", %{
      userid: socket.assigns.current_user.id
    })

    {:noreply, assign(socket, users: users, challenges: challenges)}
  end

  def handle_event("create-table", _payload, socket) do
    Tables.create_table(socket.assigns.current_user, :blue)
    {:noreply, socket}
  end

  def handle_event("cancel-table", %{"owner" => owner}, socket) do
    Tables.cancel_table(owner)
    {:noreply, socket}
  end

  def handle_event(
        "join-table",
        %{
          "owner" => owner,
          "owner-id" => owner_id,
          "owner-color" => "blue"
        },
        socket
      ) do
    game_slug =
      Games.new_game(
        :blue,
        owner,
        socket.assigns.current_user.username
      )

    TictactwoWeb.Endpoint.broadcast(@events_topic <> owner_id, "room-created", %{
      game_slug: game_slug
    })

    Tables.cancel_table(owner)
    Tables.cancel_table(socket.assigns.current_user.username)

    {:noreply, redirect_to_game(socket, game_slug)}
  end

  def handle_event("outside-click", _, socket) do
    {:noreply, socket}
  end

  def handle_event("key-event", _, socket) do
    {:noreply, socket}
  end

  def handle_event("switch-tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, tab)}
  end

  ## ---- HANDLE INFO ----

  def handle_info(:after_join, socket) do
    TictactwoWeb.Endpoint.subscribe(@lobby_topic)
    TictactwoWeb.Endpoint.subscribe(@events_topic <> socket.assigns.current_user.id)
    TictactwoWeb.Endpoint.subscribe(CurrentGames.topic())
    TictactwoWeb.Endpoint.subscribe(@tables_topic)

    Presence.track(
      self(),
      @lobby_topic,
      socket.assigns.current_user.id,
      %{
        id: socket.assigns.current_user.id,
        username: socket.assigns.current_user.username
      }
    )

    {count, current_games} = CurrentGames.get_current_games()
    tables = Tables.get_current_tables()

    {:noreply,
     assign(socket,
       loading: false,
       current_games_count: count,
       current_games: current_games,
       tables: tables
     )}
  end

  def handle_info(
        %{event: "presence_diff", payload: _payload},
        %{assigns: _assigns} = socket
      ) do
    users = Presence.list_presences(@lobby_topic)

    {:noreply, assign(socket, users: users)}
  end

  def handle_info(%{event: "challenge-received", payload: payload}, socket) do
    {:noreply, assign(socket, challenges: [payload.challenger | socket.assigns.challenges])}
  end

  def handle_info(
        %{event: "challenge-accepted", payload: %{userid: userid, game_slug: game_slug}},
        socket
      ) do
    # send the other player an event to join the room
    TictactwoWeb.Endpoint.broadcast(@events_topic <> userid, "room-created", %{
      game_slug: game_slug
    })

    # redirect the challenger to the game room
    {:noreply, redirect_to_game(socket, game_slug)}
  end

  def handle_info(
        %{event: "challenge-rejected", payload: %{userid: userid}},
        socket
      ) do
    users =
      socket.assigns.users
      |> Map.update!(userid, fn prev ->
        prev
        |> Map.update!(:status, &toggle_status/1)
      end)

    socket =
      socket
      |> assign(:users, users)

    {:noreply, socket}
  end

  def handle_info(%{event: "room-created", payload: %{game_slug: game_slug}}, socket) do
    {:noreply, redirect_to_game(socket, game_slug)}
  end

  # Handle current games change event
  def handle_info(%{event: "current-games-updated", payload: {count, current_games}}, socket) do
    socket =
      socket
      |> assign(:current_games, current_games)
      |> assign(:current_games_count, count)

    {:noreply, socket}
  end

  # Handle table update event 
  def handle_info(%{event: "tables_updated", payload: tables}, socket) do
    {:noreply, assign(socket, :tables, tables)}
  end

  ## ---- PRIVATE FUNCTIONS ----

  @spec toggle_status(challenge_status()) :: challenge_status()
  defp toggle_status(:challenge_sent), do: nil
  defp toggle_status(_), do: :challenge_sent

  defp redirect_to_game(socket, game_slug) do
    push_redirect(socket, to: "/rooms/#{game_slug}")
  end

  ## ---- VIEW FUNCTIONS ----

  def filter_self(users, current_username) do
    Enum.filter(users, fn {_user_id, user_data} -> user_data.username != current_username end)
  end

  def show_active_content(js \\ %JS{}, tab) do
    js
    |> JS.push("switch-tab", value: %{"tab" => tab})
    |> JS.hide(to: "div.tab-content")
    |> JS.show(
      to: "#content-tab-#{tab}",
      transition: {"ease-out duration-300", "opacity-0", "opacity-100"},
      time: 300
    )
  end

  def player_has_table?(tables, username) do
    tables
    |> Enum.any?(fn table -> table.owner == username end)
  end

  def player_owns_table?(table, username) do
    table.owner == username
  end
end
