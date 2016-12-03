defmodule BurgerbotBrain.Worker do
  alias BurgerbotBrain.SessionStore

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def receive_message({provider, session_id, msg}) do
    GenServer.cast(__MODULE__, {:message, provider, session_id, msg})
  end

  # Private API
  
  def handle_cast({:message, :facebook, session_id, msg}, _state) do
    alias BurgerbotBrain.Facebook.{Normalize, Correct, Understand, Respond, Remember}

    spawn_link fn ->
      context = SessionStore.get(session_id)
      {context, msg}
      |> Normalize.process
      |> Correct.process
      |> Understand.process
      |> Respond.process
      |> Remember.process
    end

    {:noreply, nil}
  end
end
