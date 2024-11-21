defmodule TokenBucketRateLimiterTest do
  use ExUnit.Case

  alias TokenBucketRateLimiter

  setup do
    TokenBucketRateLimiter.start()
    :ok
  end

  test "allows requests within the bucket capacity" do
    Enum.each(1..5, fn _ ->
      assert {:ok, "200 Request allowed"} = TokenBucketRateLimiter.check_request("user1", 5, 1)
    end)
  end

  test "blocks requests exceeding the bucket capacity" do
    Enum.each(1..5, fn _ ->
      assert {:ok, "200 Request allowed"} = TokenBucketRateLimiter.check_request("user2", 5, 1)
    end)

    assert {:error, "429 Too Many Requests"} = TokenBucketRateLimiter.check_request("user2", 5, 1)
  end

  test "refills tokens over time" do
    assert {:ok, "200 Request allowed"} = TokenBucketRateLimiter.check_request("user3", 5, 1)
    Enum.each(1..4, fn _ ->
      TokenBucketRateLimiter.check_request("user3", 5, 1)
    end)

    assert {:error, "429 Too Many Requests"} = TokenBucketRateLimiter.check_request("user3", 5, 1)
    :timer.sleep(2000) # Wait for refill
    assert {:ok, "200 Request allowed"} = TokenBucketRateLimiter.check_request("user3", 5, 1)
  end
end
