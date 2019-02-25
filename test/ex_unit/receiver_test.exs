defmodule ExUnit.ReceiverTest do
  use ExUnit.Case
  use ExUnit.Receiver
  doctest ExUnit.Receiver

  setup do
    start_receiver(0)
    :ok
  end

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

  describe "Registry" do
    test "can get the state of the registry" do
      assert get_receiver() == 0
    end

    test "can update the state of the registry" do
      assert increment(1)
      assert get_receiver() == 1
    end
  end

  describe "Example module" do
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
