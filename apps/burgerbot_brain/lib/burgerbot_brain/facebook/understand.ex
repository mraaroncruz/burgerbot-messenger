defmodule BurgerbotBrain.Facebook.Understand do
  require Logger

  alias BurgerbotBrain.Facebook.Parse

  def process({context, message} = data) do
    understand(context, Parse.parse(data))
  end

  defp understand(context, {:greet, msg} = intent) do
    {context, intent}
  end

  defp understand(context, {:find_text_location, msg} = intent) do
    case GoogleMaps.coords(msg) do
      {:ok, coords} ->
        context = Map.put(context, :coords, coords)
        intent = {:location, msg}
        {context, intent}
      {:error, reason} ->
        Logger.error("Error getting coords for users text location: #{reason}")
        intent = {:location_error, msg}
        {context, intent}
    end
  end

  defp understand(context, {:find_coords_location, msg} = intent) do
    {context, {:location, msg}}
  end

  defp understand(context, {:choose_venue_type, msg, value: value} = intent) do
    context = Map.put(context, :venue_type, value)
    {context, {:choose_venue_type, msg}}
  end

  defp understand(context, {:choose_view_more_venues, msg, value: value} = intent) do
    context = Map.put(context, :more_venues, value)
    {context, {:choose_view_more_venues, msg}}
  end

  defp understand(context, {:unknown, msg} = intent) do
    {context, intent}
  end
end
