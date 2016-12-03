defmodule BurgerbotBrain.UserSession do
  defstruct state: :start,
            user_id: nil,
            id: nil,
            failure_count: 0,
            venues: [],
            coords: nil,
            current_page: 1
end
