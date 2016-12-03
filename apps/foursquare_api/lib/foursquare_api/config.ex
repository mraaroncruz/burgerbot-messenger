defmodule FoursquareApi.Config do
  defstruct [:base_uri, :client_id, :client_secret, :version]

  def get do
    base_uri      = "https://api.foursquare.com/v2"
    version       = "20160919"
    client_id     = Application.get_env(:foursquare_api, :client_id)
    client_secret = Application.get_env(:foursquare_api, :client_secret)

    %__MODULE__{base_uri: base_uri, client_id: client_id, client_secret: client_secret, version: version}
  end
end
