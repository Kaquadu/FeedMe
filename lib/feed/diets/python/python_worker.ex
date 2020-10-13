defmodule Feed.PythonWorker do
  use GenServer

  # @name {:global, __MODULE__}

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_opts) do
    path = [:code.priv_dir(:feed), "python"]
          |> Path.join() |> to_charlist()

    {:ok, pid} = :python.start([{ :python_path, path }, { :python, 'python3' }])

    IO.inspect pid, label: "Python PID"

    {:ok, pid}
  end

  def handle_call({:call_function, module, function_name, arguments}, _sender, pid) do
    result = :python.call(pid, module, function_name, arguments)
    {:reply, result, pid}
  end

  def call_python_function(file_name, function_name, arguments) do
    GenServer.call(__MODULE__, {:call_function, file_name, function_name, arguments}, 5_000)
  end
  # :c.pid(0,612,0) |> Process.alive?
end
