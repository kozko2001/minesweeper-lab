defmodule Minesweeper.GameTest do
  use ExUnit.Case
  alias Minesweeper.Game

  # Setup block for initializing a default game state
  setup do
    game = Game.new_game(8, 8, 10)
    %{game: game}
  end

  describe "new_game/3" do
    test "initializes a game with the correct board size and mine count", %{game: game} do
      assert length(game.board) == 8
      assert length(hd(game.board)) == 8

      mine_count =
        Enum.reduce(game.board, 0, fn row, acc ->
          acc +
            Enum.count(row, fn cell ->
              Map.get(cell, :mine, false) == true
            end)
        end)

      assert mine_count == 10
    end
  end

  describe "reveal_cell/3" do
    board = [
      [%{mine: true, revealed: false}, %{mine: false, revealed: false}],
      [%{mine: false, revealed: false}, %{mine: false, revealed: false}]
    ]

    test "does nothing if the cell is already revealed", %{game: game} do
      board =
        List.update_at(game.board, 0, fn row ->
          List.update_at(row, 1, &Map.put(&1, :revealed, true))
        end)

      game = %{game | board: board}

      updated_game = Game.reveal_cell(game, 0, 1)

      assert updated_game == game
    end

    test "marks a cell as revealed if it is not already revealed", %{game: game} do
      updated_game = Game.reveal_cell(game, 0, 1)

      assert Enum.at(Enum.at(updated_game.board, 0), 1).revealed == true
      assert updated_game.game_over == false
    end

    test "sets the game_over flag to true if a mine is revealed", %{game: game} do
      updated_game = Game.reveal_cell(game, 0, 0)

      assert Enum.at(Enum.at(updated_game.board, 0), 0).revealed == true
      assert updated_game.game_over == true
    end
  end
end
