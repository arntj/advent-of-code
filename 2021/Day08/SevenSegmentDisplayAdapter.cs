namespace Day08
{
    public static class SevenSegmentDisplayAdapter
    {
        public static int CountUniqueDigits(string[] input)
        {
            return input
                .Select(line => line
                    .Split(" | ")
                    .Last()
                    .Split(' ')
                    .Count(sign => new[] { 2, 3, 4, 7 }.Contains(sign.Length)))
                .Sum();
        }

        public static int InterpretAndAddSignals(string[] input)
        {
            return input
                .Select(InterpretAndAddLine)
                .Sum();
        }

        private static int InterpretAndAddLine(string line)
        {
            string[] parts = line.Split(" | ");

            List<List<char>> decodedSignals = DeduceSignals(parts[0]);

            return parts[1]
                .Split(' ')
                // Using the decoded signals to interpret the input
                .Select(o => decodedSignals.FindIndex(s => s.Count() == o.Length && s.All(o.Contains)))
                // Multiply to the power of 10 according to the index
                .Select((n, i) => (int)Math.Pow(10, 3 - i) * n)
                .Sum();
        }

        private static List<List<char>> DeduceSignals(string input)
        {
            List<string> signals = input.Split(' ').ToList();
            List<char>[] decodedSignals = new List<char>[10];

            // deduce the easy ones (unique number of segment)
            decodedSignals[1] = signals.RemoveAndReturn(s => s.Length == 2).ToList();
            decodedSignals[4] = signals.RemoveAndReturn(s => s.Length == 4).ToList();
            decodedSignals[7] = signals.RemoveAndReturn(s => s.Length == 3).ToList();
            decodedSignals[8] = signals.RemoveAndReturn(s => s.Length == 7).ToList();

            // figure out the harder ones
            decodedSignals[6] = signals.RemoveAndReturn(s => s.Length == 6 && !decodedSignals[1].All(c => s.Contains(c))).ToList();
            decodedSignals[9] = signals.RemoveAndReturn(s => s.Length == 6 && decodedSignals[4].All(c => s.Contains(c))).ToList();
            decodedSignals[3] = signals.RemoveAndReturn(s => s.Length == 5 && decodedSignals[1].All(c => s.Contains(c))).ToList();

            // 0 remains when the other six-segment ones have been figured out
            decodedSignals[0] = signals.RemoveAndReturn(s => s.Length == 6).ToList();

            // for the last ones we need to know what segment is in 1 but not in 6
            char actuallyC = decodedSignals[1].Single(c => !decodedSignals[6].Contains(c));

            decodedSignals[2] = signals.RemoveAndReturn(s => s.Contains(actuallyC)).ToList();
            decodedSignals[5] = signals.Single().ToList();

            return decodedSignals.ToList();
        }
    }
}
