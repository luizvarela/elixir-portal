defmodule Portal do
  use Application
  defstruct [:left, :right]

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Portal.Worker, [arg1, arg2, arg3]),
      worker(Portal.Door, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :simple_one_for_one, name: Portal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def transfer(left, right, data) do
    for item <- data do
      Portal.Door.push(left, item)
    end

    %Portal{left: left, right: right}
  end

  def push_right(portal) do
    case Portal.Door.pop(portal.left) do
      :error   -> :ok
      {:ok, h} -> Portal.Door.push(portal.right, h)
    end

    portal
  end

  #def push_right(portal) do
    #  portal portal, :left, :right
  #end

  def push_left(portal) do
    push(portal, :right, :left)
  end

  def push(portal, source, target) do
    case Map.get(portal, source) |> Portal.Door.pop do
      :error   -> :ok
      {:ok, h} -> Portal.Door.push(Map.get(portal, target), h)
    end
  end

  def shoot(color) do
    Supervisor.start_child(Portal.Supervisor, [color])
  end
end

defimpl Inspect, for: Portal do
  def inspect(%Portal{left: left, right: right}, _) do
    left_door  = inspect(left)
    right_door = inspect(right)

    left_data  = inspect(Enum.reverse(Portal.Door.get(left)))
    right_data = inspect(Portal.Door.get(right))

    max = max(String.length(left_door), String.length(left_data))

    """
    #Portal<
      #{String.rjust(left_door, max)} <=> #{right_door}
      #{String.rjust(left_data, max)} <=> #{right_data}
    >
    """
  end
end
