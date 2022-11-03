defmodule Tictactwo.Types do
  defmacro __using__(_opts) do
    quote do
      @type game_status() ::
              :ready
              | :in_play
              | :blue_won
              | :orange_won
              | {:aborted, String.t()}
              | {:resigned, String.t()}
      @type player() :: :blue | :orange
      @type gobbler_name() :: :xl | :large | :medium | :small | :xs | :premie
      @type gobbler() :: %{
              name: gobbler_name(),
              status: gobbler_status()
            }
      @type cells :: [cell()]
      @type cell() :: %{
              coords: coords(),
              gobblers: [{player(), gobbler_name()}]
            }
      @type row :: pos_integer()
      @type col :: pos_integer()
      @type coords :: {row(), col()}
      @type gobbler_status :: :not_selected | :selected | {:played, coords()}
      @type selected_gobbler ::
              nil
              | %{
                  name: gobbler_name(),
                  played?: coords() | nil
                }
      @type game :: %{
              slug: String.t(),
              status: game_status(),
              player_turn: player(),
              blue_username: String.t(),
              orange_username: String.t(),
              blue: [gobbler()],
              orange: [gobbler()],
              cells: [cell()],
              selected_gobbler: selected_gobbler(),
              timers: %{
                blue: pos_integer(),
                orange: pos_integer()
              }
            }
      @type viewer_type :: :blue | :orange | :spectator
      @type current_user :: %{username: String.t()}
      @type challenge_status :: :challenge_sent | nil
    end
  end
end
