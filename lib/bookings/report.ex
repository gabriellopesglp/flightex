defmodule Flightex.Bookings.Report do
  alias Flightex.Bookings.Agent, as: BookingAgent
  alias Flightex.Bookings.Booking

  def generate_report(from_date, to_date) do
    with {:ok, formated_from_date} <- NaiveDateTime.from_iso8601(from_date),
         {:ok, formated_to_date} <- NaiveDateTime.from_iso8601(to_date) do
      BookingAgent.list_all()
      |> Map.values()
      |> Enum.filter(fn booking ->
        filter_by_date(booking, formated_from_date, formated_to_date)
      end)
      |> create()
    else
      {:error, :invalid_format} ->
        {:error, "Invalid date format. Example of valid format: YYYY-MM-DD hh:mm:ss"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp filter_by_date(%Booking{complete_date: data}, from_date, to_date) do
    case greater_than?(NaiveDateTime.compare(data, from_date)) do
      true ->
        case greater_than?(NaiveDateTime.compare(to_date, data)) do
          true ->
            true

          _ ->
            false
        end

      _ ->
        false
    end
  end

  defp greater_than?(compared_value) when compared_value in [:gt, :eq], do: true
  defp greater_than?(_compared_value), do: false

  defp create(bookings) do
    bookings_list = build_bookings_list(bookings)
    date_in_seconds = System.system_time(:second)
    filename = "bookings_report_#{date_in_seconds}.csv"
    File.write(filename, bookings_list)
    {:ok, "Report generated successfully"}
  end

  defp build_bookings_list(bookings) do
    bookings
    |> Enum.map(fn booking -> booking_string(booking) end)
  end

  defp booking_string(%Booking{
         complete_date: data,
         local_origin: origem,
         local_destination: destino,
         user_id: id_usuario
       }) do
    "#{id_usuario},#{origem},#{destino},#{data}\n"
  end
end
