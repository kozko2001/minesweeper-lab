defmodule Minesweeper.Repo do
  use Ecto.Repo,
    otp_app: :minesweeper,
    adapter: Ecto.Adapters.SQLite3
end
