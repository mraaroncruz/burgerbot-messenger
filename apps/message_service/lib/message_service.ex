defmodule MessageService do
  use Application

  alias MessageService.Messenger.Sender
  alias MessageService.SessionStore

  alias BurgerbotBrain, as: Bot

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      worker(MessageService.SessionStore, []),
    ]
    opts = [strategy: :one_for_one, name: MessageService.Supervisor]
    Supervisor.start_link(children, opts)
  end


  # Public API


  def receive(:facebook, %{"entry" => [%{"messaging" => messages}]} = message) do
    alias MessageService.Messenger.{Mapper, SessionHandler}
    # TODO: CLEAN THIS UP... GROSS
    for m <- messages do
      res =
        SessionHandler.receive(m)
        |> Mapper.receive
      case res do
        {:ok, %{session: session, text: text}} ->
          spawn(fn ->
            Bot.receive_message(session.id, [text: text], :facebook)
          end)
        {:ok, %{session: session, attachments: attachments}} ->
          Bot.receive_message(session.id, [attachments: attachments], :facebook)
        :noop -> nil
      end
    end
  end
  def receive(provider, message) do
    IO.puts "Received message for unknown provider #{provider}: #{inspect(message)}"
  end

  def send(%{provider: provider, message: message, session: session_id}) do
    session = get_session(provider, session_id)
    _send(provider, message, session)
  end

  defp _send(:facebook, message, session) do
    %{ metadata: session.id }
    |> Map.merge(message)
    |> Sender.send(session.user_id)
    IO.puts "Send message to messenger: #{inspect(message)} for session #{inspect(session)}"
  end
  
  defp get_session(provider, session_id) do
    SessionStore.from_session_id(provider, session_id)
  end

  def logout(%{provider: provider, session: session_id}) do
    Logger.info("Logging out user")
    SessionStore.logout_user(provider, session_id)
  end

  # Utils

  defp atom_keys(map) do
    for {key, val} <- map, into: %{} do
      cond do
        is_binary(key) -> {String.to_atom(key), val}
        true           -> {key, val}
      end
    end
  end
end
