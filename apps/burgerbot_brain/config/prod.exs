use Mix.Config

config :burgerbot_brain, :wit_ai_access_token, System.get_env("WITAI_ACCESS_TOKEN")

config :foursquare_api,
  client_id: System.get_env("FOURSQUARE_CLIENT_ID"),
  client_secret: System.get_env("FOURSQUARE_SECRET")
