defmodule Flightex.Bookings.Agent do
  use Agent

  alias Flightex.Bookings.Booking

  def start_link(_initial_state) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def save(%Booking{} = booking) do
    uuid = UUID.uuid4()

    Agent.update(__MODULE__, &update_state(&1, booking, uuid))

    {:ok, uuid}
  end

  def get(uudi), do: Agent.get(__MODULE__, &get_booking(&1, uudi))

  defp get_booking(state, uuid) do
    case Map.get(state, uuid) do
      nil -> {:error, "Booking not found"}
      booking -> {:ok, booking}
    end
  end

  defp update_state(state, %Booking{} = booking, uuid), do: Map.put(state, uuid, booking)
end
