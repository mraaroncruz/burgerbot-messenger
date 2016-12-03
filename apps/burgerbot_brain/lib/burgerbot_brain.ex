defmodule BurgerbotBrain do

  use Application

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      worker(BurgerbotBrain.SessionStore, []),
      worker(BurgerbotBrain.Worker, []),
    ]
    opts = [strategy: :one_for_one, name: BurgerbotBrain.Supervisor]
    Supervisor.start_link(children, opts)
  end

  alias BurgerbotBrain.{SessionStore, UserSession}

  @token Application.get_env(:burgerbot_brain, :wit_ai_access_token)


  # Public API


  def receive_message(session, message, provider) do
    BurgerbotBrain.Worker.receive_message({provider, session, message})
  end


  # Utils


  defp log(message), do: Logger.warn message
end
