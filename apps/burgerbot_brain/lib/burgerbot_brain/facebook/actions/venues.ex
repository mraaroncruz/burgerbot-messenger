defmodule BurgerbotBrain.Facebook.Actions.Venues do
  alias Messenger.{GenericTemplate, Button, QuickReplies}
  alias BurgerbotBrain.{VenueFinder, SessionStore, UserSession}

  require Logger

  @venue_page_count 4

  # Public API

  def find(context) do
    send_venue_list(context, context.venues)
  end

  def show_more(context) do
    send_venue_list(context, context.venues)
  end

  # Private API

  defp send_venue_list(%{venue_type: type, coords: coords} = context, []) do
    venues = case type do
      :burgers -> VenueFinder.find_burgers(coords)
      :beer    -> VenueFinder.find_beer(coords)
      :both    -> VenueFinder.find_both(coords)
      _ ->
        Logger.error("Not searching for burgers, beer or both. Type is #{type}. Shouldn't be possible to get here")
        []
    end

    send_venues_message(venues, context)
    context
    |> Map.put(:venues, venues)
    |> Map.put(:current_page, context.current_page + 1)
  end
  defp send_venue_list(context, venues) do
    send_venues_message(venues, context)
    context
    |> Map.put(:current_page, context.current_page + 1)
  end

  defp send_venues_message(venues, context) do
    template = venues
    |> Enum.drop((context.current_page - 1) * @venue_page_count)
    |> Enum.take(@venue_page_count)
    |> Enum.reduce(%GenericTemplate{}, &map_to_template/2)

    m = cond do
      Enum.any?(template.elements) ->
        %{provider: :facebook, message: GenericTemplate.to_map(template), session: context.id}
      true ->
        %{provider: :facebook, message: %{text: "That's all the venues for your area"}, session: context.id}
    end

    MessageService.send(m)
    send_more_message(context)
  end

  defp map_to_template(venue, template) do
    subtitle = venue.address <> " " <> venue.rating
    button = %Button{type: "web_url", title: "See Details", url: venue.url}
    GenericTemplate.add(
      template,
      venue.name,
      venue.url,
      venue.map_url,
      subtitle,
      [button]
    )
  end

  defp send_more_message(context) do
    qr = %QuickReplies{}
    |> QuickReplies.add("Yes", "view_more_venues")
    |> QuickReplies.add("No", "end_conversation")
    |> QuickReplies.to_map

    message = %{
      text: "Do you want to see more?",
      quick_replies: qr,
    }

    MessageService.send(%{provider: :facebook, message: message, session: context.id})
  end
end
