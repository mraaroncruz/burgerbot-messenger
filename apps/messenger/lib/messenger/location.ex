defmodule Messenger.Location do
  defstruct text: "What's your location?"

  def to_map(location, text \\ nil) do
    %{
      text: text || location.text,
      quick_replies: [
        %{
          content_type: "location",
        }
      ]
    }
  end
end
