namespace Day06
{
    public static class LanternfishSpawner
    {
        public static long RunForDays(string input, int days)
        {
            IEnumerable<int> initialFishes = input.Split(',').Select(int.Parse);

            // creating an array to count how many fishes will be spawned every day
            long[] spawns = new long[days];

            // add initial fishes
            foreach(int f in initialFishes)
            {
                for (int i = f; i < days; i += 7)
                {
                    spawns[i] += 1;
                }
            }

            // working through every day and gradually add more fish as they spawn
            for (int i = 0; i < days; i++)
            {
                long newFishes = spawns[i];
                if (newFishes > 0)
                {
                    // adding spawn rates for new fishes
                    for (int j = i + 9; j < days; j += 7)
                    {
                        spawns[j] += newFishes;
                    }
                }
            }

            return initialFishes.Count() + spawns.Sum();
        }
    }
}
