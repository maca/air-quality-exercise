defmodule GithubClient.MockServer do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/intensity" do
    rec = record("1970-01-01T00:00:00Z", 1, 2)
    conn |> Plug.Conn.send_resp(200, body([rec]))
  end

  get "/intensity/date/:date" do
    time = conn.params["date"] |> Timex.parse!("{YYYY}-{0M}-{0D}")
    time2 = Timex.set(time, minute: 30)
    rec = record(time, 1, 2)
    rec2 = record(time2, 2, 3)

    conn |> Plug.Conn.send_resp(200, body([rec, rec2]))
  end

  defp body(records) do
    Poison.encode!(%{data: records})
  end

  defp record(time, actual, forecast) do
    %{ from: time, intensity: %{ actual: actual, forecast: forecast } }
  end
end
