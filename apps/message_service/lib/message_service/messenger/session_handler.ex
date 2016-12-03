defmodule MessageService.Messenger.SessionHandler do
  alias MessageService.SessionStore

  def receive(%{"sender" => %{"id" => sender_id}} = message) do
    %{message: message, session: SessionStore.find_or_create(:facebook, sender_id)}
  end
end
