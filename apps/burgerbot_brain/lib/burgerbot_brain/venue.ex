defmodule BurgerbotBrain.Venue do
  defstruct ~w(coords distance_m name url image_url map_url rating distance address)a

  def from_foursquare(fs_venue) do
    %{
      "id" => id,
      "name" => name,
      "location" => %{
        "lat" => lat,
        "lng" => lng,
        "distance" => dist,
      } = loc
    } = fs_venue

    addr = case loc["address"] do
      nil -> ""
      res -> res
    end

    r = case fs_venue["rating"] do
      nil ->  "" 
      res  -> "#{res} / 10"
    end

    coords = [lat, lng]

    %__MODULE__{
      coords: coords,
      address: addr,
      name: name,
      url: "https://foursquare.com/v/#{id}",
      rating: r,
      distance_m: dist,
      distance: distance(dist),
      map_url: map_url(coords)
    }
  end

  defp distance(d) when d < 1000 do
    "#{d} m"
  end
  defp distance(d) do
    "#{d / 1000.0} km"
  end

  defp map_url(coords) do
    "https://maps.googleapis.com/maps/api/staticmap?center=#{coords |> Enum.join(",")}&markers=#{marker(coords)}&zoom=13&scale=2&size=600x300&maptype=roadmap"
  end

  defp marker(coords, color \\ "red") do
    ~s[color:red|#{coords |> Enum.join(",")}]
  end
end
