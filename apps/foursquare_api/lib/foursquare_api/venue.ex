defmodule FoursquareApi.Venue do
  alias FoursquareApi.Config

  require Logger

  def search(lat, lng, category_ids, radius \\ 15000, limit \\ 50) do
    %{
      ll: [lat, lng] |> Enum.join(","),
      intent: :browse,
      categoryId: category_ids |> Enum.join(","),
      limit: limit,
      radius: radius,
      venuePhotos: 1,
    }
    |> uri("search", Config.get)
    |> make_request
  end

  defp make_request(uri) do
    case HTTPoison.get(uri) do
      {:ok, resp} -> {:ok, resp}
      {:error, reason} ->
        Logger.error("Error requesting foursquare data: #{inspect(reason)}")
        :error
    end
  end

  defp uri(attrs, endpoint, config) do
    auth = %{
      client_id: config.client_id,
      client_secret: config.client_secret,
      v: config.version,
    }
    base_uri(config) <> "/" <> endpoint <> "?" <> URI.encode_query(attrs |> Map.merge(auth))
  end

  defp base_uri(config) do
    config.base_uri <> "/venues"
  end
end
