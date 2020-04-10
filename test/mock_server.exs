defmodule GithubClient.MockServer do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/intensity" do
    conn |> Plug.Conn.send_resp(200, body([record(1)]))
  end

  defp body(records) do
    Poison.encode!(%{data: records})
  end

  defp record(num) do
    time = "1970-01-01T00:00:0#{num}Z"
    %{ from: time, intensity: %{ actual: num, forecast: num + 1 } }
  end
end
