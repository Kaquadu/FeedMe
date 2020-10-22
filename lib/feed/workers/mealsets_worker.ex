defmodule Feed.Workers.MealsetsWorker do
  use GenServer

  alias Feed.Diets

  @schedule_time 60 * 60 * 1_000

  def init(_opts) do
    send(self(), :check_meals)
    {:ok, []}
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_info(:check_meals, state) do
    Diets.get_diets()
    |> Enum.map(fn diet ->
      Diets.request_daily_meals(diet.id)
    end)
    |> Enum.any?(fn x -> x not in [{:error, "Already enqueued"}, {:error, "Already calculated"}, :ok] end)
    |> if do
      raise RuntimeError, message: "Problem while requesting diet"
    else
      :ok
    end

    schedule_work(@schedule_time)

    {:noreply, state}
  end

  def schedule_work(time) do
    Process.send_after(self(), :check_meals, time)
  end

end
