Code.require_file("test/mock_server.exs")

children = [{ Plug.Cowboy,
              scheme: :http,
              plug: GithubClient.MockServer,
              options: [port: 8081]
            }]

Supervisor.start_link(children, strategy: :one_for_one)

ExUnit.start()
