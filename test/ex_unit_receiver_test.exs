defmodule ExUnitReceiverTest.Runner do
  defmacro run_tests do
    alias ExUnit.ExUnitReceiverTest.Example

    quote do
      test "can get the state of the registry" do
        assert get_receiver() == 0
      end

      test "can update the state of the registry" do
        assert increment(1)
        assert get_receiver() == 1
      end

      test "side effects can be tested with an anonymous function" do
        assert get_receiver() == 0
        assert Example.cause_side_effects(:normal, fn x -> increment(x) end, [1]) == :normal
        assert get_receiver() == 1
      end

      test "side effects can be tested with a named function" do
        assert get_receiver() == 0
        assert Example.cause_side_effects(:normal, __MODULE__, :increment, [1]) == :normal
        assert get_receiver() == 1
      end
    end
  end
end

defmodule ExUnit.ExUnitReceiverTest do
  use ExUnit.Case
  use ExUnitReceiver
  import ExUnitReceiverTest.Runner
  doctest ExUnitReceiver

  defmodule Example do
    def cause_side_effects(status, fun, args) do
      apply(fun, args)
      status
    end

    def cause_side_effects(status, module, fun, args) do
      apply(module, fun, args)
      status
    end
  end

  def increment(num) do
    update_receiver(&(&1 + num))
  end

  describe "initializes with a value" do
    setup do
      start_receiver(0)
      :ok
    end

    run_tests()
  end

  describe "initializes with a function" do
    setup do
      start_receiver(fn -> 0 end)
      :ok
    end

    run_tests()
  end

  describe "initializes with a module, function, and arguments" do
    setup do
      start_receiver(Kernel, :-, [1, 1])
      :ok
    end

    run_tests()
  end

  describe "start_receiver/1 starts process under test supervisor" do
    setup do
      start_receiver([])
      :ok
    end

    test "receiver is not started under the Receiver.Supervisor" do
      assert Supervisor.which_children(Receiver.Supervisor) == []
    end
  end
end
