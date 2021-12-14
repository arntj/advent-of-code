namespace Day14
{
    public static class Polymerizator
    {
        public static long InsertPolymers(string[] input, int steps)
        {
            string template = input[0];
            Dictionary<string, char> insertionRules =
                input[2..].ToDictionary(line => line[..2] + "", line => line[6]);

            Dictionary<string, long> polymerPairs = new();

            for (int i = 1; i < template.Length; i++)
            {
                string currentPair = template[(i - 1)..(i + 1)] + "";
                IncrementOrAdd(polymerPairs, currentPair, 1L);
            }

            Dictionary<char, long> counts = new();

            foreach (char c in template)
            {
                IncrementOrAdd(counts, c, 1L);
            }

            foreach (char c in insertionRules.Values)
            {
                if (!counts.ContainsKey(c))
                {
                    counts[c] = 0L;
                }
            }

            for (int n = 0; n < steps; n++)
            {
                var currentPolymerPairs = polymerPairs.ToList();

                foreach ((string pair, long count) in currentPolymerPairs)
                {
                    if (insertionRules.ContainsKey(pair))
                    {
                        polymerPairs[pair] = Math.Max(0L, polymerPairs[pair] - count);

                        char newElement = insertionRules[pair];

                        IncrementOrAdd(polymerPairs, "" + pair[0] + newElement, count);
                        IncrementOrAdd(polymerPairs, "" + newElement + pair[1], count);


                        IncrementOrAdd(counts, newElement, count);
                    }
                }
            }

            var countNumbers = counts.Values;

            return countNumbers.Max() - countNumbers.Min();
        }

        private static void IncrementOrAdd<T>(Dictionary<T, long> dict, T key, long toAdd) where T : notnull
        {
            if (dict.ContainsKey(key))
            {
                dict[key] += toAdd;
            }
            else
            {
                dict[key] = toAdd;
            }
        }
    }
}
