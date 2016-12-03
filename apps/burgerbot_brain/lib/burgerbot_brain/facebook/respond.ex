defmodule BurgerbotBrain.Facebook.Respond do
  @moduledoc """
  Here is where the message actually gets sent back to facebook
  """

  alias BurgerbotBrain.Facebook.Actions

  def process({context, {intent, msg}}) do
    process(context, intent, msg)
  end

  defp process(context, :greet = intent, _msg) do
    Actions.StartConversation.process(context)
    {context, intent}
  end

  defp process(context, :location = intent, _msg) do
    Actions.Default.ask_burgers_or_beers(context)
    {context, intent}
  end

  defp process(context, :choose_venue_type = intent, _msg) do
    context =  Actions.Venues.find(context)
    {context, intent}
  end

  # Anything that isn't a strict no (or nope) falls through to wanting more

  defp process(context, :choose_view_more_venues = intent, _msg) do
    case context.more_venues do
      :no -> 
        Actions.EndConversation.process(context)
        {context, :destroy}
      _ -> 
        context =  Actions.Venues.show_more(context)
        {context, intent}
    end
  end

  # This would be a good spot to use wit.ai or something
 
  defp process(context, :unknown, _msg) do
    context =
      context
      |> Actions.Default.dont_understand
      |> Map.put(:failure_count, context.failure_count + 1)
    {context, context.state}
  end
end
