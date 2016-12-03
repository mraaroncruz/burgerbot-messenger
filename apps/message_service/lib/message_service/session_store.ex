defmodule MessageService.SessionStore do
  use GenServer

  defmodule Session do
    defstruct [:user_id, :id]
  end

  @moduledoc """
    %{
      facebook: %{
        "i_am_user_id"  => "I_AM_UUID",
        "i_am_user_id2" => "I_AM_UUID2",
      }
    }
  """

  def start_link do
    GenServer.start_link(__MODULE__, %{facebook: %{}}, name: __MODULE__)
  end

  def from_session_id(provider, session_id) do
    GenServer.call(__MODULE__, {:from_session_id, provider, session_id})
  end

  def from_user_id(provider, user_id) do
    GenServer.call(__MODULE__, {:from_user_id, provider, user_id})
  end

  def find_or_create(provider, user_id) do
    case from_user_id(provider, user_id) do
      nil  -> GenServer.call(__MODULE__, {:create, provider, user_id})
      sesh -> sesh
    end
  end

  def logout_user(provider, session_id) do
    GenServer.cast(__MODULE__, {:destroy, provider, session_id})
  end

  # Private API

  def handle_call({:from_user_id, provider, user_id}, _from, state) do
    case state[provider][user_id] do
      nil -> {:reply, nil, state}
      id  -> {:reply, %Session{user_id: user_id, id: id}, state}
    end
  end

  def handle_call({:from_session_id, provider, session_id}, _from, state) do
    user_data = Enum.find(state[provider], fn {_user_id, id} -> 
      session_id == id
    end)
    case user_data do
      nil -> {:reply, nil, state}
      {user_id, sesh_id} -> {:reply, %Session{user_id: user_id, id: sesh_id}, state}
    end
  end

  def handle_call({:create, provider, user_id}, _from, state) do
    session_id = generate_id
    sesh = %Session{user_id: user_id, id: session_id }
    new_state = put_in(state, [provider, user_id], session_id)
    {:reply, sesh, new_state}
  end

  def handle_cast({:destroy, provider, session_id}, state) do
    case state[provider]
    |> Enum.find(fn {_k,v} -> v == session_id end) do
      {user_id, _ } -> {:noreply, put_in(state, [provider, user_id], nil)}
      _             -> {:noreply, state}
    end
  end

  defp generate_id do
    UUID.uuid4(:weak)
  end
end
