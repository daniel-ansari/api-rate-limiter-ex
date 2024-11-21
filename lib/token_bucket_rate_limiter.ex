defmodule TokenBucketRateLimiter do
  @moduledoc """
  A token bucket rate limiter.
  """

  @ets_table :token_bucket_table
  @default_limit 5
  @refill_rate 1 # Tokens added per second

  def start do
    :ets.new(@ets_table, [:set, :public, :named_table])
    IO.puts("Token Bucket Rate Limiter started.")
  end

  def check_request(user_id, limit \\ @default_limit, refill_rate \\ @refill_rate) do
    now = :os.system_time(:second)

    case :ets.lookup(@ets_table, user_id) do
      [] ->
        :ets.insert(@ets_table, {user_id, limit - 1, now})
        {:ok, "200 Request allowed"}

      [{^user_id, tokens, last_refill_time}] ->
        elapsed = now - last_refill_time
        new_tokens = min(limit, tokens + elapsed * refill_rate)

        if new_tokens >= 1 do
          :ets.insert(@ets_table, {user_id, new_tokens - 1, now})
          {:ok, "200 Request allowed"}
        else
          {:error, "429 Too Many Requests"}
        end
    end
  end
end

# Example Tests:
# TokenBucketRateLimiter.start()
# Enum.each(1..10, fn _ -> IO.inspect(TokenBucketRateLimiter.check_request("user1", 5, 2)) end)
# :timer.sleep(2000)
# IO.inspect(TokenBucketRateLimiter.check_request("user1"))
