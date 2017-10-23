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
