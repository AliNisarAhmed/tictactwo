defmodule Tictactwo.Types do
  defmacro __using__(_opts) do
    quote do
      @type player() :: :blue | :orange
      @type gobbler_name() :: :xl | :large | :medium | :small | :xs | :premie
      @type gobbler() :: %{
              name: gobbler_name(),
              status: gobbler_status()
            }
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
                  name: gobbler(),
                  played?: coords() | nil
                }
      @type game :: %{
              player_turn: player(),
              blue: %{
                username: String.t(),
                gobblers: [gobbler()]
              },
              orange: %{
                username: String.t(),
                gobblers: [gobbler()]
              },
              cells: [cell()],
              selected_gobbler: selected_gobbler()
            }
    end
  end
end
