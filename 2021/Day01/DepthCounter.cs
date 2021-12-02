namespace Day01
{
    public static class DepthCounter
    {
        public static int CountIncreases(string[] lines, int n)
        {
            var numbers = lines.Select(int.Parse).ToList();
            int result = 0;

            for (int i = 0; i < numbers.Count() - n; i++)
            {
                int firstSum = numbers.Skip(i).Take(n).Sum();
                int secondSum = numbers.Skip(i + 1).Take(n).Sum();

                if (secondSum > firstSum)
                {
                    result++;
                }
            }

            return result;
        }
    }
}
