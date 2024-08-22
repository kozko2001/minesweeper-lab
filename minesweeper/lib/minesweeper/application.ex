defmodule Minesweeper.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MinesweeperWeb.Telemetry,
      Minesweeper.Repo,
      {DNSCluster, query: Application.get_env(:minesweeper, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Minesweeper.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Minesweeper.Finch},
      # Start a worker by calling: Minesweeper.Worker.start_link(arg)
      # {Minesweeper.Worker, arg},
      # Start to serve requests, typically the last entry
      MinesweeperWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Minesweeper.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MinesweeperWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
