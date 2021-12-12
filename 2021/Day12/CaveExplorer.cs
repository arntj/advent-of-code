namespace Day12
{
    public record Cave(string Name)
    {
        public List<Cave> ConnectedCaves = new();
        public bool Big => Name.ToUpper() == Name;
    }

    public static class CaveExplorer
    {
        private const string START_CAVE = "start";
        private const string END_CAVE = "end";

        public static int FindPaths(string[] input, bool canTraverseTwice)
        {
            Cave start = BuildCave(input);
            return TraveseCaves(new() { start }, canTraverseTwice);
        }

        private static int TraveseCaves(List<Cave> traversedCaves, bool canTraverseTwice)
        {
            Cave currentCave = traversedCaves.Last();

            if (currentCave.Name == END_CAVE)
            {
                return 1;
            }

            int result = 0;

            foreach (Cave cave in currentCave.ConnectedCaves)
            {
                List<Cave> nextTraversedCaves = traversedCaves.ToList(); // clone list
                nextTraversedCaves.Add(cave);

                if (!ValidPath(nextTraversedCaves, canTraverseTwice))
                {
                    continue;
                }

                result += TraveseCaves(nextTraversedCaves, canTraverseTwice);
            }

            return result;
        }

        private static bool ValidPath(List<Cave> traversedCaves, bool canTraverseTwice)
        {
            // Only first cave can be start cave
            if (traversedCaves.Skip(1).Any(c => c.Name == START_CAVE))
            {
                return false;
            }

            var groups = traversedCaves
                .Where(c => !c.Big)
                .GroupBy(c => c.Name);

            if (canTraverseTwice)
            {
                return
                    groups.Where(g => g.Count() == 2).Count() <= 1
                    && !groups.Any(g => g.Count() > 2);
            }

            return !groups.Any(g => g.Count() > 1);
        }

        private static Cave BuildCave(string[] input)
        {
            Dictionary<string, Cave> caves = new();

            foreach (string line in input)
            {
                string[] parts = line.Split('-');
                string from = parts[0];
                string to = parts[1];

                if (!caves.ContainsKey(from))
                {
                    caves[from] = new Cave(from);
                }

                if (!caves.ContainsKey(to))
                {
                    caves[to] = new Cave(to);
                }

                caves[from].ConnectedCaves.Add(caves[to]);
                caves[to].ConnectedCaves.Add(caves[from]);
            }

            return caves[START_CAVE];
        }
    }
}
