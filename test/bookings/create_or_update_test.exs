defmodule Flightex.Bookings.CreateOrUpdateTest do
  use ExUnit.Case, async: false

  import Flightex.Factory

  alias Flightex.Bookings.{Agent, CreateOrUpdate}
  alias Flightex.Users.Agent, as: UserAgent

  describe "call/1" do
    setup do
      Flightex.start_agents()

      :ok
    end

    test "when all params are valid, returns a valid tuple" do
      cpf = "12345678900"

      user = build(:users, cpf: cpf)
      UserAgent.save(user)

      params = %{
        complete_date: ~N[2001-05-07 03:05:00],
        local_origin: "Brasilia",
        local_destination: "Bananeiras",
        user_id: cpf
      }

      {:ok, uuid} = CreateOrUpdate.call(params)

      {:ok, response} = Agent.get(uuid)

      expected_response = %Flightex.Bookings.Booking{
        complete_date: ~N[2001-05-07 03:05:00],
        id: response.id,
        local_destination: "Bananeiras",
        local_origin: "Brasilia",
        user_id: "12345678900"
      }

      assert response == expected_response
    end
  end
end
