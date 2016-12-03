defmodule Messenger.GenericTemplate do
  defstruct elements: []

  defmodule Element do
    alias Messenger.Button

    defstruct [:title, :item_url, :image_url, :subtitle, :buttons]

    def to_map(struct) do
      Map.from_struct(struct)
      |> Map.update!(:buttons, fn (btns) ->
        btns |> Enum.map(&Button.to_map/1)
      end)
    end
  end

  def add(struct, title, item_url, image_url, subtitle, buttons \\ []) do
    element = %Element{title: title, item_url: item_url, image_url: image_url, subtitle: subtitle, buttons: buttons }

    %__MODULE__{ struct |
      elements: [element | struct.elements]
    }
  end

  def to_map(struct) do
    elements = struct.elements
    |> Enum.reverse
    |> Enum.map &Element.to_map/1

    template = %{
      attachment: %{
        type: "template",
        payload: %{
          template_type: "generic",
          elements: elements,
        }
      }
    }
  end
end
