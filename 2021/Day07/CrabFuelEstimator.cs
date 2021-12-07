namespace Day07
{
    public static class CrabFuelEstimator
    {
        public static int EstimatePartOne(string input)
        {
            Func<int, int, int> fuelEstimator = (int fromPos, int toPos) => Math.Abs(fromPos - toPos);

            return EstimateLeastFuelConsumption(input, fuelEstimator);
        }

        public static int EstimatePartTwo(string input)
        {
            Func<int, int, int> fuelEstimator = (int fromPos, int toPos) => SumConsecutiveNumbers(Math.Abs(fromPos - toPos));

            return EstimateLeastFuelConsumption(input, fuelEstimator);
        }

        private static int EstimateLeastFuelConsumption(string input, Func<int, int, int> fuelEstimator)
        {
            IEnumerable<int> crabs = input.Split(',').Select(int.Parse);

            return Enumerable
                .Range(0, crabs.Max() + 1)
                .Select(pos => crabs.Select(c => fuelEstimator(c, pos)).Sum())
                .Min();
        }

        private static int SumConsecutiveNumbers(int toN)
        {
            return toN * (toN + 1) / 2;
        }
    }
}
