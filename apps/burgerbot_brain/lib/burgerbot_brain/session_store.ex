defmodule BurgerbotBrain.SessionStore do
  use GenServer

  alias BurgerbotBrain.UserSession

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get(session_id) do
    GenServer.call(__MODULE__, {:get, session_id})
  end

  def save(session) do
    GenServer.cast(__MODULE__, {:save, session})
  end

  def destroy(session) do
    GenServer.cast(__MODULE__, {:destroy, session.id})
  end

  # Private API
  
  def handle_call({:get, session_id}, _from, state) do
    session = state[session_id] || %UserSession{id: session_id}
    {:reply, session, state}
  end

  def handle_cast({:save, session}, state) do
    state = Map.put(state, session.id, session)
    {:noreply, state}
  end

  def handle_cast({:destroy, id}, state) do
    state = Map.delete(state, id)
    {:noreply, state}
  end
end
