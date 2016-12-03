defmodule BurgerbotBrain.Facebook.Correct do
  @moduledoc """
  This is where you correct any grammar coming in from the outside
  """
  def process({context, msg}) do
    process(context, msg)
  end

  # Just pushing this through atm
  defp process(context, msg), do: {context, msg}
end


