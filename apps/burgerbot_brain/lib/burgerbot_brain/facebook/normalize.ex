defmodule BurgerbotBrain.Facebook.Normalize do
  @moduledoc """
  Takes the message and normalizes Location, Postback, normal messages into something the
  rest of the pipeline will understand
  """

  require Logger

  def process({context, msg}) do
    process(context, msg)
  end

  defp process(context, [attachments: attachments]) do
    case attachments do
      [%{"payload" => %{"coordinates" => %{"lat" => lat, "long" => lng}}}] ->
        {Map.put(context, :coords, [lat, lng]), "location"}
      _ ->
        Logger.error("Don't know how to deal with attachments: #{inspect attachments}")
        {context, :unknown}
    end
  end

  defp process(context, [text: text]) do
    {context, text}
  end
end
