defmodule Feed.Workers.DietsWorker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def insert_diet_request(diet_id) do
    GenServer.cast(__MODULE__, {:insert_diet_request, diet_id})
  end

  def check_diet(diet_id) do
    GenServer.call(__MODULE__, {:check_diet, diet_id})
  end

  def complete_diet_request(diet_id) do
    GenServer.call(__MODULE__, {:complete_diet_request, diet_id})
  end

  def handle_cast({:insert_diet_request, diet_id}, %{diets_table: table_pid} = table_pids) do
    tomorrows_date = Date.utc_today() |> Timex.shift(days: 1)
    :ets.insert(table_pid, {diet_id, tomorrows_date})
    Task.start(Feed.Diets, :get_daily_meals, [diet_id])

    {:noreply, table_pids}
  end

  def handle_call({:check_diet, diet_id}, _from, %{diets_table: table_pid} = table_ids) do
    result = :ets.lookup(table_pid, diet_id)
    {:reply, result, table_ids}
  end

  def handle_call({:complete_diet_request, diet_id}, %{diets_table: table_pid} = table_pids) do
    result = :ets.delete(table_pid, diet_id)
    {:reply, result, table_pids}
  end

  def init(_init_state) do
    diets_table_pid = :ets.new(:calculating_diets, [:named_table, read_concurrency: true])
    {:ok, %{diets_table: diets_table_pid}}
  end
end
