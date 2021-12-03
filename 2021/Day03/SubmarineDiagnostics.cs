namespace Day03
{
    public static class SubmarineDiagnostics
    {
        public static int GetPowerConsumption(string[] report)
        {
            int len = report.First().Length;

            int[] mostCommonBits = MostCommonBits(report);
            int[] leastCommonBits = LeastCommonBits(report);

            int gamma = mostCommonBits
                .Select((d, i) => d * Math.Pow(2, len - i - 1))
                .Select(Convert.ToInt32)
                .Sum();

            int epsilon = leastCommonBits
                .Select((d, i) => d * Math.Pow(2, len - i - 1))
                .Select(Convert.ToInt32)
                .Sum();

            return gamma * epsilon;
        }

        public static int GetLifeSupportRating(string[] report)
        {
            var oxygenFilter = report.ToList();
            int currBit = 0;

            while (oxygenFilter.Count() > 1)
            {
                int mostCommonBit = MostCommonBit(oxygenFilter, currBit);
                oxygenFilter = oxygenFilter.Where(line => line[currBit].ToString() == mostCommonBit.ToString()).ToList();
                currBit++;
            }

            var co2Filter = report.ToList();
            currBit = 0;

            while (co2Filter.Count() > 1)
            {
                int leastCommonBit = LeastCommonBit(co2Filter, currBit);
                co2Filter = co2Filter.Where(line => line[currBit].ToString() == leastCommonBit.ToString()).ToList();
                currBit++;
            }

            int oxygen = Convert.ToInt32(oxygenFilter.Single(), 2);
            int co2 = Convert.ToInt32(co2Filter.Single(), 2);

            return oxygen * co2;
        }

        private static int[] MostCommonBits(IEnumerable<string> input)
        {
            return Enumerable.Range(0, input.First().Length).Select(i => MostCommonBit(input, i)).ToArray();
        }

        private static int[] LeastCommonBits(IEnumerable<string> input)
        {
            return Enumerable.Range(0, input.First().Length).Select(i => LeastCommonBit(input, i)).ToArray();
        }

        private static int MostCommonBit(IEnumerable<string> input, int index)
        {
            var ones = input.Select(line => line[index]).Where(bit => bit == '1');

            return ones.Count() >= Math.Ceiling(input.Count() / 2.0) ? 1 : 0;
        }

        private static int LeastCommonBit(IEnumerable<string> input, int index)
        {
            var ones = input.Select(line => line[index]).Where(bit => bit == '1');

            return ones.Count() < Math.Ceiling(input.Count() / 2.0) ? 1 : 0;
        }
    }
}
