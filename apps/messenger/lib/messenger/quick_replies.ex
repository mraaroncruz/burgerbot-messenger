defmodule Messenger.QuickReplies do
  defmodule QuickReply do
    defstruct [:text, :action]
  end

  defstruct quick_replies: []

  def add(struct, text, action) do
    qr = %QuickReply{text: text, action: action}
    %__MODULE__{ struct | quick_replies: [qr | struct.quick_replies]}
  end

  def to_map(struct) do
    for qr <- Enum.reverse(struct.quick_replies) do
      %{
        content_type: "text",
        title: qr.text,
        payload: qr.action,
     }
    end
  end
end
