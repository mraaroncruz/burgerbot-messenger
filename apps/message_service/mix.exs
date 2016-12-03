defmodule MessageService.Mixfile do
  use Mix.Project

  def project do
    [app: :message_service,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [
      :logger,
      :facebook_messenger,
      :burgerbot_brain,
      :uuid,
    ],
     mod: {MessageService, []}]
  end

  defp deps do
    [
      { :uuid, "~> 1.1" },
      { :burgerbot_brain, in_umbrella: true },
      { :facebook_messenger, github: "SpacemanLabs/facebook_messenger" },
    ]
  end
end
