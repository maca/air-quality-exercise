import Config

config :mnesia, dir: 'mnesia/#{Mix.env}/Mnesia.#{node()}'

import_config "#{Mix.env}.exs"
