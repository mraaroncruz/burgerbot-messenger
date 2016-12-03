defmodule BurgerbotBrain.Facebook.Actions.Default do
  alias Messenger.{QuickReplies}
  alias BurgerbotBrain.{SessionStore}

  require Logger

  def ask_burgers_or_beers(session) do
    qr = %QuickReplies{}
    |> QuickReplies.add("Burgers", "user_chose_burgers")
    |> QuickReplies.add("Beer",    "user_chose_beer")
    |> QuickReplies.add("Both",    "user_chose_both")
    |> QuickReplies.to_map

    message = %{
      text: "What are you looking for?",
      quick_replies: qr,
    }

    MessageService.send(%{provider: :facebook, message: message, session: session.id})
  end

  def dont_understand(context) do
    wat = [
      "I don't understand what you're trying to say",
      "Excuse me?",
      "I didn't get that",
      "I missed that last thing, could you clarify please",
    ]
    message = %{
      text: wat |> Enum.shuffle |> hd
    }
    MessageService.send(%{provider: :facebook, message: message, session: context.id})
    context
  end
end
