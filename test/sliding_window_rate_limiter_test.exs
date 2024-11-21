defmodule SlidingWindowRateLimiterTest do
  use ExUnit.Case

  alias SlidingWindowRateLimiter

  setup do
    SlidingWindowRateLimiter.start()
    :ok
  end

  test "allows requests within the limit" do
    Enum.each(1..5, fn _ ->
      assert {:ok, "200 Request allowed"} = SlidingWindowRateLimiter.check_request("user1", 5, 60)
    end)
  end

  test "blocks requests exceeding the limit" do
    Enum.each(1..5, fn _ ->
      assert {:ok, "200 Request allowed"} = SlidingWindowRateLimiter.check_request("user2", 5, 60)
    end)

    assert {:error, "429 Too Many Requests"} = SlidingWindowRateLimiter.check_request("user2", 5, 60)
  end

  test "handles partial counts from previous window" do
    assert {:ok, "200 Request allowed"} = SlidingWindowRateLimiter.check_request("user3", 5, 2)
    :timer.sleep(1500) # Wait halfway into the next window
    assert {:ok, "200 Request allowed"} = SlidingWindowRateLimiter.check_request("user3", 5, 2)
  end
end
