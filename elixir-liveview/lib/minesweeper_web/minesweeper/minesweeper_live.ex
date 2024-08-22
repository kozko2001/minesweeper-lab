defmodule MinesweeperWeb.MinesweeperLive do
  use Phoenix.LiveView
  alias Minesweeper.Game

  def mount(_params, _session, socket) do
    game = Game.new_game()
    {:ok, assign(socket, game: game)}
  end

  def handle_event("reveal", %{"row" => row, "col" => col}, socket) do
    row = String.to_integer(row)
    col = String.to_integer(col)
    game = socket.assigns.game |> Game.reveal_cell(row, col)
    {:noreply, assign(socket, game: game)}
  end

  def handle_event("new_game", _params, socket) do
    game = Game.new_game()
    {:noreply, assign(socket, game: game)}
  end

  def handle_event("toggle_flag", %{"row" => row, "col" => col}, socket) do
    row = String.to_integer(row)
    col = String.to_integer(col)
    game = socket.assigns.game |> Game.toggle_flag(row, col)
    {:noreply, assign(socket, game: game)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Minesweeper</h1>

      <%= if @game.game_over do %>
        <%= if @game.game_won do %>
          <h2>You won!</h2>
        <% else %>
          <h2>Game Over!</h2>
        <% end %>
        <button phx-click="new_game" class="new-game">Start New Game</button>
      <% else %>
        <div class="board">
          <%= for row <- 0..@game.rows-1 do %>
            <div class="row">
              <%= for col <- 0..@game.cols-1 do %>
                <button
                  class={cell_class(@game.board, row, col)}
                  phx-click="reveal"
                  phx-value-row={row}
                  phx-value-col={col}
                  phx-contextmenu="toggle_flag"
                  data-row={row}
                  data-col={col}
                  phx-hook="FlagCell"
                  id={"cell-#{row}-#{col}"}
                >
                  <%= render_cell(@game.board, row, col) %>
                </button>
              <% end %>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp cell_class(board, row, col) do
    cell = Enum.at(Enum.at(board, row), col)

    cond do
      Map.get(cell, :flagged, false) ->
        "flagged"

      !Map.get(cell, :revealed, false) ->
        ""

      Map.get(cell, :mine, false) ->
        "mine revealed"

      true ->
        "revealed"
    end
  end

  defp render_cell(board, row, col) do
    cell = Enum.at(Enum.at(board, row), col)

    cond do
      Map.get(cell, :flagged, false) ->
        "🚩"

      !Map.get(cell, :revealed, false) ->
        "?"

      Map.get(cell, :mine, false) ->
        "💣"

      true ->
        count = Map.get(cell, :neighboring_mines)
        "#{count}"
    end
  end
end
