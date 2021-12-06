namespace Day06
{
    public static class LanternfishSpawner
    {
        public static long RunForDays(string input, int days)
        {
            IEnumerable<int> initialFishes = input.Split(',').Select(int.Parse);

            // create an index for how many fishes is in each state (days left to next spawn)
            long[] fishes = Enumerable.Range(0, 9).Select(i => (long)initialFishes.Count(fish => fish == i)).ToArray();

            for (int i = 0; i < days; i++)
            {
                long fishesToSpawn = fishes[0];

                // shift all fishes one position to the left (subtract one day to next spawn)
                for (int j = 1; j < fishes.Length; j++)
                {
                    fishes[j - 1] = fishes[j];
                }

                // spawn new fishes
                fishes[8] = fishesToSpawn;

                // the fishes that spawned now have seven days till next spawn
                fishes[6] += fishesToSpawn;
            }

            return fishes.Sum();
        }
    }
}
