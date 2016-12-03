defmodule BurgerbotBrain.MessageStream do
  @moduledoc """
  Creates a Stream of new messages coming

  {worker, stream} = MessageStream.create_stream
  send worker, {:message, "hello world"}
  send worker, {:message, "goodbye world"}
  stream
  |> Enum.take(2)
  # => ["hello world", "goodbye world"]
  """

  def create_stream(timeout \\ :infinity) do
    parent = self()
    pid = spawn_link fn -> stream(parent) end
    strm = Stream.repeatedly(
      fn ->
        receive_next_message(timeout)
      end
    )
    {pid, strm}
  end

  def receive_next_message(timeout) do
    receive do
      {:message, msg} -> {:message, msg}
      after
        timeout -> {:error, "Receive next message timed out"}
    end
  end

  defp stream(parent) do
    receive do
      {:message, msg} -> send(parent, {:message, msg})
    end
    stream(parent)
  end
end
