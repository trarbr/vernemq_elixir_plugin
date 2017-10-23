defmodule VernemqElixirPlugin.Mixfile do
  use Mix.Project

  def project do
    [app: :vernemq_elixir_plugin,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      extra_applications: [:logger],
      mod: {VernemqElixirPlugin.Application, []},
      env: [vmq_plugin_hooks()],
    ]
  end

  defp vmq_plugin_hooks do
    hooks = [
      {VernemqElixirPlugin, :auth_on_register, 5, []},
      {VernemqElixirPlugin, :on_register, 3, []},
      {VernemqElixirPlugin, :on_client_wakeup, 1, []},
      {VernemqElixirPlugin, :on_client_offline, 1, []},
      {VernemqElixirPlugin, :on_client_gone, 1, []},
      {VernemqElixirPlugin, :on_register, 3, []},
      {VernemqElixirPlugin, :on_register, 3, []},
      {VernemqElixirPlugin, :auth_on_subscribe, 3, []},
      {VernemqElixirPlugin, :on_subscribe, 3, []},
      {VernemqElixirPlugin, :on_unsubscribe, 3, []},
      {VernemqElixirPlugin, :auth_on_publish, 6, []},
      {VernemqElixirPlugin, :on_publish, 6, []},
      {VernemqElixirPlugin, :on_deliver, 4, []},
      {VernemqElixirPlugin, :on_offline_message, 5, []}
    ]
    {:vmq_plugin_hooks, hooks}
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:distillery, "~> 1.5", runtime: false}]
  end
end
