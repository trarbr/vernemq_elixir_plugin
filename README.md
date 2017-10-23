# VernemqElixirPlugin

This repo is a basic example of writing a VerneMQ plugin in Elixir. It's based on info provided in [this issue](https://github.com/erlio/vernemq/issues/440).

If you want try and build the plugin yourself you can follow the guide below. The code in this repo is identical to what you'll have when you're done.

## Prerequisites

The guide comes with a Vagrantfile that sets up an environment with:

- Ubuntu 16.04
- VerneMQ 1.2.0 (installed with binary from VerneMQ's download page)
- Erlang 19.3.6
- Elixir 1.4.5
- Mosquitto clients (for testing)

However, the guide should be applicate to any OS that VerneMQ runs on, and work with any Erlang/Elixir version as long as they are compatible with the Erlang version VerneMQ has been compiled against.

If you already have a compatible environment you can skip the Vagrant setup. Otherwise, you can create the Vagrant environment by running `vagrant up` ([install vagrant](https://www.vagrantup.com/downloads.html) if you don't have it already).

## Project setup

First create a new project by running `mix new vernemq_elixir_plugin --sup`.

We'll use [distillery](https://hex.pm/packages/distillery) to compile our project into an Erlang release. This makes it easier to use as a VerneMQ plugin as it will bundle Elixir with your code.

Add `distillery` as a dependency by adding it to your `mix.exs` file:

```elixir
defp deps do
  [
    {:distillery, "~> 1.5", runtime: false},
  ]
end
```

Then run `mix deps.get` and generate the release configuration file with `mix release.init`.

VerneMQ is going to load your application into its own instance of the Erlang VM. For this reason, we don't need to include ERTS. Open `rel/config.exs` and specify:

```elixir
environment :prod do
  set include_erts: false
  ...
end
```

## Writing the code

The first thing VerneMQ will do when starting your plugin is to call the `start/2` function in your application module. Let's leave a print statement so we can check it's been started. Open `lib/vernemq_elixir_plugin/application.ex` and add this line at the top of the `start/2` function:

```elixir
  def start(_type, _args) do
    IO.puts("*** VernemqElixirPlugin starting")
    ...
  end
```

We'll implement a handler for all VerneMQ hooks - see [the docs](https://vernemq.com/docs/plugindevelopment/) for a description of each hook. For this basic plugin we'll simply print a message to stdout whenever a hook is called. Open `lib/vernemq_elixir_plugin.ex`and replace the text there with the following:

```elixir
defmodule VernemqElixirPlugin do
  # Session lifecycle
  def auth_on_register(_peer, {_mountpoint, clientid}, _username, _password, _clean_session?) do
    IO.puts("*** auth_on_register #{clientid}")
    {:ok, []}
  end

  def on_register(_peer, {_mountpoint, clientid}, username) do
    IO.puts("*** on_register #{clientid} / #{username}")
    :ok
  end

  def on_client_wakeup({_mountpoint, clientid}) do
    IO.puts("*** on_client_wakeup #{clientid}")
    :ok
  end

  def on_client_offline({_mountpoint, clientid}) do
    IO.puts("*** on_client_offline #{clientid}")
    :ok
  end

  def on_client_gone({_mountpoint, clientid}) do
    IO.puts("*** on_client_gone #{clientid}")
    :ok
  end

  # Subscribe flow
  def auth_on_subscribe(_username, {_mountpoint, clientid}, topics) do
    IO.puts("*** auth_on_subscribe #{clientid}")
    {:ok, topics}
  end

  def on_subscribe(_username, {_mountpoint, clientid}, _topics) do
    IO.puts("*** on_subscribe #{clientid}")
    :ok
  end

  def on_unsubscribe(_username, {_mountpoint, clientid}, _topics) do
    IO.puts("*** on_unsubscribe #{clientid}")
    :ok
  end

  # Publish flow
  def auth_on_publish(_username, {_mountpoint, clientid}, _qos, topic, payload, _flag) do
    IO.puts("*** auth_on_publish #{clientid} / #{topic} / #{payload}")
    {:ok, payload}
  end

  def on_publish(_username, {_mountpoint, clientid}, _qos, topic, payload, _retain?) do
    IO.puts("*** on_publish #{clientid} / #{topic} / #{payload}")
    :ok
  end

  def on_deliver(_username, {_mountpoint, clientid}, topic, payload) do
    IO.puts("*** on_deliver #{clientid} / #{topic} / #{payload}")
    :ok
  end

  def on_offline_message({_mountpoint, clientid}, _qos, topic, payload, _retain?) do
    IO.puts("*** on_offline_message #{clientid} / #{topic} / #{payload}")
    :ok
  end
end
```

You'll also need to tell VerneMQ which hooks are implemented in the plugin. This is done by adding the following in the `mix.exs` file:

```elixir
  def application do
    [
      env: [vmq_plugin_hooks()],
      ...
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
```

Now all we need is to bundle the plugin. This is done with `MIX_ENV=prod mix release --env prod`.

## Enabling the plugin

The console output from the release command above should tell you the path to directory containing your release. In my case it's `/home/ubuntu/vernemq_elixir_plugin/_build/prod/rel/vernemq_elixir_plugin`. To enable the plugin you'll have to add this path to the VerneMQ configuration file. Add the following to `/etc/vernemq/vernemq.conf`:

```
plugins.vernemq_elixir_plugin = on
plugins.vernemq_elixir_plugin.path = /home/ubuntu/vernemq_elixir_plugin/_build/prod/rel/vernemq_elixir_plugin
```

Then start VerneMQ:

```sh
sudo systemctl enable vernemq
sudo systemctl start vernemq
```

## Testing the plugin

The output from the calls to `IO.puts` will be visible in the file `/var/log/vernemq/erlang.log.1`. If you open it, you should see a line with the text `*** VernemqElixirPlugin starting`.

Next, we can that the other hooks are executed by starting a subscriber and publisher. Start a subscriber in one terminal:

```sh
mosquitto_sub -t '#'
```

Use another terminal to publish messages:

```sh
mosquitto_pub -t 'hello' -m 'vernemq plugin in elixir!'
```

If you check `/var/log/vernemq/erlang.log.1` you should see that all the messages for the hooks have been printed!
