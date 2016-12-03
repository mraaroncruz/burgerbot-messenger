defmodule BurgerbotBrain.Facebook.Actions.EndConversation do
  alias BurgerbotBrain.{SessionStore}

  def process(context) do
    MessageService.send(%{provider: :facebook, message: %{text: "OK. See you soon"}, session: context.id})
    MessageService.logout(%{provider: :facebook, session: context.id})
  end
end
