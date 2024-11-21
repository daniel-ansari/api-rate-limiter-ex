defmodule FixedWindowRateLimiterTest do
  use ExUnit.Case

  alias FixedWindowRateLimiter

  setup do
    FixedWindowRateLimiter.start()
    :ok
  end

  test "allows requests within the limit" do
    Enum.each(1..5, fn _ ->
      assert {:ok, "200 Request allowed"} = FixedWindowRateLimiter.check_request("user1", 5, 60)
    end)
  end

  test "blocks requests exceeding the limit" do
    Enum.each(1..5, fn _ ->
      assert {:ok, "200 Request allowed"} = FixedWindowRateLimiter.check_request("user2", 5, 60)
    end)

    assert {:error, "429 Too Many Requests"} = FixedWindowRateLimiter.check_request("user2", 5, 60)
  end

  test "resets count after the time window" do
    assert {:ok, "200 Request allowed"} = FixedWindowRateLimiter.check_request("user3", 5, 2)
    :timer.sleep(3000) # Wait for window reset
    assert {:ok, "200 Request allowed"} = FixedWindowRateLimiter.check_request("user3", 5, 2)
  end
end
