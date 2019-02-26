defmodule ExUnitReceiver do
  @moduledoc """
  Documentation for ExUnitReceiver.
  """

  defmacro __using__(opts) do
    quote do
      use Receiver, unquote(Keyword.merge(opts, test: true))
    end
  end
end
