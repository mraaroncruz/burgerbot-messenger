defmodule BurgerbotBrain.Facebook.Remember do
  alias BurgerbotBrain.SessionStore

  @moduledoc """
  This is where you persist the new context
  """
  def process({context, intent}) do
    process(context, intent)
  end

  defp process(context, :destroy) do
    SessionStore.destroy(context)
  end

  defp process(context, intent) do
    new_state = intent
    context   = Map.put(context, :state, new_state)
    commit_to_memory(context)
    IO.puts "Finished with #{intent}\nContext: #{inspect context}"
  end

  defp commit_to_memory(context) do
    user = SessionStore.get(context.id)
    user = Map.merge(user, context)
    SessionStore.save(user)
  end
end

