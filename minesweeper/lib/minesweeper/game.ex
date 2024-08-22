defmodule Minesweeper.Game do
  defstruct board: [], rows: 8, cols: 8, mines: 10, game_over: false, game_won: false

  def new_game(rows \\ 8, cols \\ 8, mines \\ 10) do
    # Initialize board with mines and empty cells
    %__MODULE__{
      board: initialize_board(rows, cols, mines),
      rows: rows,
      cols: cols,
      mines: mines
    }
  end

  defp initialize_board(rows, cols, mines) do
    rows = 8
    cols = 8

    empty_board =
      for r <- 1..rows,
          do:
            for(
              c <- 1..cols,
              do: %{
                mine: false,
                neighboring_mines: 0,
                revealed: false,
                flagged: false
              }
            )

    mine_positions = generate_mine_positions(rows, cols, mines)

    board_with_mines = place_mines(empty_board, mine_positions)

    board_with_numbers = calculate_neighboring_mines(board_with_mines)

    board_with_numbers
  end

  defp generate_mine_positions(rows, cols, mines) do
    positions = for row <- 0..(rows - 1), col <- 0..(cols - 1), do: {row, col}
    positions |> Enum.shuffle() |> Enum.take(mines)
  end

  defp place_mines(board, mine_positions) do
    Enum.reduce(mine_positions, board, fn {row, col}, acc ->
      List.update_at(acc, row, fn r ->
        List.update_at(r, col, fn cell -> %{cell | mine: true} end)
      end)
    end)
  end

  defp calculate_neighboring_mines(board) do
    for {row, row_index} <- Enum.with_index(board) do
      for {cell, col_index} <- Enum.with_index(row) do
        if cell.mine do
          cell
        else
          neighboring_mines = count_neighboring_mines(board, row_index, col_index)
          %{cell | neighboring_mines: neighboring_mines}
        end
      end
    end
  end

  defp count_neighboring_mines(board, row, col) do
    neighbors = [
      {row - 1, col - 1},
      {row - 1, col},
      {row - 1, col + 1},
      {row, col - 1},
      {row, col + 1},
      {row + 1, col - 1},
      {row + 1, col},
      {row + 1, col + 1}
    ]

    neighbors
    |> Enum.filter(fn {r, c} ->
      r >= 0 and r < length(board) and c >= 0 and c < length(List.first(board))
    end)
    |> Enum.count(fn {r, c} -> board |> Enum.at(r) |> Enum.at(c) |> Map.get(:mine) end)
  end

  def reveal_cell(game = %Minesweeper.Game{}, row, col) do
    board = game.board
    cell = Enum.at(Enum.at(board, row), col)

    if Map.get(cell, :revealed, false) do
      game
    else
      updated_cell = Map.put(cell, :revealed, true)

      updated_board =
        List.update_at(board, row, fn r ->
          List.update_at(r, col, fn _ -> updated_cell end)
        end)

      cond do
        Map.get(updated_cell, :mine, false) ->
          %{game | board: updated_board, game_over: true}

        check_win_condition(game) ->
          %{game | game_won: true, game_over: true, board: updated_board}

        true ->
          %{game | board: updated_board}
      end
    end
  end

  def toggle_flag(game = %Minesweeper.Game{}, row, col) do
    board = game.board

    updated_board =
      List.update_at(board, row, fn r ->
        List.update_at(r, col, fn cell ->
          Map.update(cell, :flagged, true, &(!&1))
        end)
      end)

    %{game | board: updated_board}
  end

  defp check_win_condition(game) do
    Enum.all?(game.board, fn row ->
      Enum.all?(row, fn cell ->
        (Map.get(cell, :mine) && !Map.get(cell, :revealed)) ||
          (!Map.get(cell, :mine) && Map.get(cell, :revealed))
      end)
    end)
  end
end
