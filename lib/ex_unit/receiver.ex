defmodule ExUnit.Receiver do
  @moduledoc """
  Documentation for ExUnit.Receiver.
  """

  defmacro __using__(opts) do
    {name, []} = Keyword.pop(opts, :name, :receiver)
    module_name =
      __CALLER__.module
      |> Module.split()
      |> Enum.concat([Atom.to_string(name) |> Macro.camelize()])
      |> Module.concat()

    quote bind_quoted: [name: name, module_name: module_name] do
      import ExUnit.Receiver

      @module_name module_name

      quote do: alias(module_name)

      defmodule module_name do
        use Agent

        def start_link(args) do
          Agent.start_link(fn -> args end, name: __MODULE__)
        end

        def get do
          Agent.get(__MODULE__, & &1)
        end

        def update(fun) do
          Agent.update(__MODULE__, fun)
        end
      end

      def unquote(:"start_#{name}")(args \\ []) do
        start_supervised({@module_name, args})
      end

      def unquote(:"get_#{name}")() do
        @module_name.get()
      end

      def unquote(:"update_#{name}")(fun) do
        @module_name.update(fun)
      end
    end
  end
end