defmodule BurgerbotBrain.Facebook.Parse do
  require Logger

  @moduledoc """
  Burgerbot is a bot that gives locations of beer and burgers near the user.

  The conversation should go like:

  -- state: :greet, context: %{}
  User: "Hi"
  Bot: "Hey there. I'd like to show you some beer and burger joints near you. But first I'm going to need your location. Could you share your location (best) or tell me the city, state and or country you're in.
  User: **Location** or "location string"
  -- state: :received_location, context: %{coords: [lat, lng], last_location_lookup: <Timestamp>}

  Bot: What are you looking for? <Burgers> <Beer> <Both>
  User: Beer
  -- state: :chose_venue_type, context: %{coords: [lat, lng], venue_type: "Beer", venues: %{venue_type: [venues]}, page: 1, last_location_lookup: <Timestamp>}

  Bot: Here are some venues **List of Venues**
  Bot: Would you like to see more? <Yes> <No> <I want to see *Opposite venue type*>
  User: Yes
  -- state: :chose_venue_type, context: %{coords: [lat, lng], venue_type: "Beer", venues: %{venue_type: [venues]}, page: 2, last_location_lookup: <Timestamp>}

  Bot: **List of Venues**
  Bot: Would you like to see more? <Yes> <No> <I want to see *Opposite venue type*>
  User: I want to see Burgers
  -- state: :chose_venue_type, context: %{coords: [lat, lng], venue_type: "Burgers", venues: %{venue_type: [venues], venue_type_2: [venues]}, page: 1, last_location_lookup: <Timestamp>}

  Bot: Would you like to see more? <Yes> <No> <I want to see *Opposite venue type*>
  User: No
  -- state: :greet, context: %{}

  Bot: Ok, see you soon!
  ...

  So we have only a few customer inputs:
  - Hi
  - Location: String or location
  - Burgers
  - Beer
  - Both
  - Yes
  - No
  - I want to see Burgers
  - I want to see Beer
  """
  @states [
    :start,
    :greet,
    :find_text_location,
    :find_coords_location,
    :location,
    :choose_venue_type,
    :choose_view_more_venues,
  ]

  @matchers [
    {:start,              ~r/get started/i},
    {:greeting,           ~r/hi|hello|heya|hey|yo|howdy/i},
    {:venue_type,         ~r/beers?|burgers?|both/i},
    {:more_venues_choice, ~r/yes|no|more/i},
    {:venue_type,         ~r/I want to see burgers|I want to see beer/i},
  ]

  def parse({context, msg} = data) do
    match_fn = fn {_, matcher} ->
      String.match?(msg, matcher)
    end

    type = case Enum.find(@matchers, match_fn) do
      nil -> :unknown
      {type, _} -> type
    end

    get_intent(context.state, type, msg)
  end

  defp get_intent(:start, :start, msg), do: {:greet, msg}

  defp get_intent(:start, :greeting, msg), do: {:greet, msg}

  defp get_intent(:greet, _, "location" = msg),  do: {:find_coords_location, msg} 

  defp get_intent(:greet, _, msg) when msg != "location", do: {:find_text_location, msg}

  # This needs to come after the location stuff. Probably a code smell
  defp get_intent(:unknown, _, msg), do: {:unknown, msg}

  defp get_intent(:location, :venue_type, msg) do
    base = {:choose_venue_type, msg}
    cond do
      String.match?(msg, ~r/burgers?/i) -> Tuple.append(base, value: :burgers)
      String.match?(msg, ~r/beers?/i)   -> Tuple.append(base, value: :beer)
      String.match?(msg, ~r/both/i)     -> Tuple.append(base, value: :both)
      true -> {:unknown, msg}
    end
  end

  defp get_intent(:choose_venue_type, :more_venues_choice, msg) do
    choose_more_venues_answer(:choose_view_more_venues, msg)
  end
  defp get_intent(:choose_view_more_venues, :more_venues_choice, msg) do
    choose_more_venues_answer(:choose_view_more_venues, msg)
  end
  defp choose_more_venues_answer(state, msg) do
    cond do
      String.match?(msg, ~r/yes/i)  -> {state, msg, value: :yes}
      String.match?(msg, ~r/no/i)   -> {state, msg, value: :no}
      String.match?(msg, ~r/more/i) -> {state, msg, value: :yes}
      true -> {:unknown, msg}
    end
  end

  defp get_intent(_, _, msg), do: {:unknown, msg}
end
