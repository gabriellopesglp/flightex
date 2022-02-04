defmodule Flightex.Bookings.ReportTest do
  use ExUnit.Case
  alias Flightex.Bookings.CreateOrUpdate
  alias Flightex.Bookings.Report
  alias Flightex.Users.Agent, as: UserAgent

  import Flightex.Factory

  describe "generate_report/2" do
    setup %{} do
      Flightex.start_agents()
      :ok
    end

    test "when all params are valid, generates the report of bookings" do
      cpf = "12345678900"

      user = build(:users, cpf: cpf)
      UserAgent.save(user)

      params1 = build(:booking)

      params2 =
        build(:booking,
          user_id: cpf,
          local_origin: "São Paulo",
          local_destination: "Santa Catarina"
        )

      CreateOrUpdate.call(params1)

      CreateOrUpdate.call(params2)

      response = Report.generate_report("2021-04-01 10:00:00", "2021-05-30 22:00:00")

      expected_response = {:ok, "Report generated successfully"}

      assert expected_response == response
    end

    test "when there is invalid params, returns an error" do
      response = Report.generate_report("2021-02-31 10:00:00", "2021-02-31 22:00:00")
      expected_response = {:error, :invalid_date}
      assert expected_response == response
    end
  end
end
