defmodule BurgerbotBrain.Facebook.Actions.StartConversation do
  def process(context) do
    msg = "Hi. If we're gonna find some burgers and beer, I'm gonna need your location."
    MessageService.send(%{
      provider: :facebook,
      session: context.id,
      message: %{text: msg}
    })
    ask_send_location(context)
    context
  end

  defp ask_send_location(context) do
    alias Messenger.Location
    message = %Location{} |> Location.to_map
    MessageService.send(%{provider: :facebook, message: message, session: context.id})
  end
end
