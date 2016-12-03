defmodule Messenger.Button do
  defstruct [:type, :title, :url, :payload]

  def to_map(struct) do
    Map.from_struct(struct)
  end
end
