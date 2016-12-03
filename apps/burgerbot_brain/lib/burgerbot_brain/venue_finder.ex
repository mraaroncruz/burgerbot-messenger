defmodule BurgerbotBrain.VenueFinder do
  @beer_category_id   "50327c8591d4c4b30a586d5d"
  @burger_category_id "4bf58dd8d48988d16c941735"

  alias BurgerbotBrain.Venue

  def find_burgers(coords) do
    search(coords, [@burger_category_id])
  end

  def find_beer(coords) do
    search(coords, [@beer_category_id])
  end

  def find_both(coords) do
    search(coords, [@burger_category_id, @beer_category_id])
  end

  defp search([lat,lng], cat_ids) do
    case FoursquareApi.Venue.search(lat, lng, cat_ids) do
      {:ok, res} -> decode(res.body)
      :error     -> []
    end
    |> map
  end

  defp map(venues) do
    venues
    |> Stream.map(&Venue.from_foursquare/1)
    |> sort
  end

  defp decode(venues) do
    Poison.decode!(venues)["response"]["venues"]
  end

  defp sort(venues) do
    venues
    |> Enum.sort(fn (v1,v2) -> v1.distance_m < v2.distance_m end)
  end
end
