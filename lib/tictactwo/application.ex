defmodule Tictactwo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TictactwoWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:tictactwo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Tictactwo.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Tictactwo.Finch},
      # Start a worker by calling: Tictactwo.Worker.start_link(arg)
      # {Tictactwo.Worker, arg},
      # Start to serve requests, typically the last entry
      TictactwoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tictactwo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TictactwoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
