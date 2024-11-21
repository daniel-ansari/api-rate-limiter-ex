defmodule SlidingWindowRateLimiter do
  @moduledoc """
  A sliding window rate limiter.
  """

  @ets_table :sliding_window_table
  @default_limit 5
  @default_window 60

  def start do
    :ets.new(@ets_table, [:set, :public, :named_table])
    IO.puts("Sliding Window Rate Limiter started.")
  end

  def check_request(user_id, limit \\ @default_limit, window \\ @default_window) do
    now = :os.system_time(:second)
    current_window = div(now, window)
    previous_window = current_window - 1
    current_time_ratio = rem(now, window) / window

    # Fetch counts for current and previous windows
    current_count = get_window_count(user_id, current_window)
    previous_count = get_window_count(user_id, previous_window)

    weighted_count = previous_count * (1 - current_time_ratio) + current_count

    if weighted_count < limit do
      :ets.update_counter(@ets_table, {user_id, current_window}, {2, 1}, {{user_id, current_window}, 0})
      {:ok, "200 Request allowed"}
    else
      {:error, "429 Too Many Requests"}
    end
  end

  defp get_window_count(user_id, window) do
    case :ets.lookup(@ets_table, {user_id, window}) do
      [] -> 0
      [{{^user_id, ^window}, count}] -> count
    end
  end
end

# Example Tests:
# SlidingWindowRateLimiter.start()
# IO.inspect(SlidingWindowRateLimiter.check_request("user1"))
# Enum.each(1..6, fn _ -> IO.inspect(SlidingWindowRateLimiter.check_request("user1")) end)
