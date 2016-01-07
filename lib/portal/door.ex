defmodule Portal.Door do

  def start_link(color) do
    Agent.start_link(fn -> [] end, name: color)
  end

  def get(door) do
    Agent.get(door, fn list -> list end)
  end

  def push(door, value) do
    Agent.update(door, fn list -> [value|list] end)
  end

  @doc"""
  Pops a value from the door.

  Returns {:ok, value} if there is a value
  or :error if the list is empty
  """
  def pop(door) do
    Agent.get_and_update(door, fn
      []    -> {:error, []}
      [h|t] -> {{:ok, h}, t}
    end)
  end
end
