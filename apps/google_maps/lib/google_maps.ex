defmodule GoogleMaps do
  @api_key  Application.get_env(:google_maps, :api_key)
  @base_url "https://maps.googleapis.com/maps/api/geocode/json"

  def coords(address) do
    case HTTPoison.get(url(address)) do
      {ok, res} ->
        case Poison.decode(res.body) do
          {:ok, parsed} -> parse(parsed)
          error -> error
        end
      error -> error
    end
  end

  defp parse(%{"results" => [ %{"geometry" => %{"location" => %{"lat" => lat, "lng" => lng}}}| _]}) do
    {:ok, [lat, lng]}
  end
  defp parse(_), do: {:error, "Can't parse coordinates from response"}

  defp url(address) do
    @base_url <> "?address=#{String.split(address, " ") |> Enum.join("+")}&key=#{@api_key}"
  end
end
