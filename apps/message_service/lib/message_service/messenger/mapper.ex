defmodule MessageService.Messenger.Mapper do
  @get_started_callback "get_started_pressed"

  # Message with Text

  def receive(%{session: session, message: %{"message" => %{"text" => text}}}) do
    {:ok, %{session: session, text: text}}
  end

  # Message with Attachments

  def receive(%{session: session, message: %{ "message" => %{"attachments" => attachments }}}) do
    {:ok, %{session: session, attachments: attachments}}
  end

  # Get Started callback

  def receive(%{session: session, message: %{"postback" => %{"payload" => callback }}}) do
    cb = @get_started_callback
    case callback do
      ^cb -> 
        {:ok, %{session: session, text: "get started"}}
      _ ->
        {:error, "unknown postback '#{callback}' from messenger"}
    end
  end

  # Other message types

  def receive(%{message: %{"read" => info}} = message) do
    IO.puts "Received 'read' message: #{inspect(message)}"
    :noop
  end

  def receive(%{message: %{"delivery" => info}} = message) do
    IO.puts "Received 'deliver' message: #{inspect(message)}"
    :noop
  end
end
