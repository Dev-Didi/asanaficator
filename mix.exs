defmodule Asanaficator.Mixfile do
  use Mix.Project

  Code.compiler_options(on_undefined_variable: :warn)
  @description """
    Simple Elixir wrapper for the Asana API
  """

  def project do
    [ app: :asanaficator,
      version: "0.0.2",
      elixir: "~> 1.0",
      name: "Asanaficator",
      description: @description,
      package: package(),
      deps: deps() ]
  end

  def application do
    IO.puts("Here we go!") 
    [ applications: [ :httpoison, :exjsx, :poison, :req] ]
  end

  defp deps do
   [ { :httpoison, "~> 2.2.1" },
     { :exjsx, "~> 3.0" },
     { :poison, "~> 5.0"},
     { :req, "~> 0.5.0"},
     { :meck, "~> 0.8.2", only: :test },
     { :earmark, "~> 0.1", only: :dev},
     { :ex_doc, "~> 0.7", only: :dev}]

  
  end

  defp package do
    [ contributors: ["Nizar Venturini"],
      licenses: ["MIT"],
      links: %{ "Github" => "https://github.com/trenpixster/asanaficator" } ]
  end

  def startup do
    client = Asanaficator.Client.new(%{access_token: "2/1206186870308538/1206267178181787:91e3819776fd34e7cff5f3eebb6ef6e2"}) 
    me = Asanaficator.User.me client
    {client, me}
  end
end
