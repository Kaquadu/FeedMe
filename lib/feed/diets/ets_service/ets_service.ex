defmodule Feed.EtsService do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_init_state) do
    auth_table_pid = :ets.new(:ets_table_name, [:set])
    {:ok, auth_table_pid}
  end

  def insert_data(key, value) do
    GenServer.cast(__MODULE__, {:insert, {key, value}})
  end

  def find_data(key) do
    GenServer.call(__MODULE__, {:find, key})
  end

  def delete_data(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  def handle_cast({:insert, {key, value}}, pid) do
    :ets.insert(pid, {key, value})
    {:noreply, pid}
  end

  def handle_cast({:delete, key}, pid) do
    :ets.delete(pid, key)
    {:noreply, pid}
  end

  def handle_call({:find, key}, _from, pid) do
    result = :ets.lookup(pid, key)
    {:reply, result, pid}
  end

end
