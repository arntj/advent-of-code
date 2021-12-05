using System.Text.RegularExpressions;

namespace Day05
{
    public static class VentDetector
    {
        public static int CountHighRiskZones(string[] input, bool considerDiagonals)
        {
            int[,] map = new int[1000, 1000];

            foreach (string line in input)
            {
                Match match = Regex.Match(line, @"^(\d+),(\d+) -> (\d+),(\d+)");
                int[] numbers = match.Groups.Values.Skip(1).Take(4).Select(g => int.Parse(g.Value)).ToArray();
                (int x1, int y1, int x2, int y2) = (numbers[0], numbers[1], numbers[2], numbers[3]);

                if (x1 == x2 || y1 == y2)
                {
                    for (int x = Math.Min(x1, x2); x <= Math.Max(x1, x2); x++)
                    {
                        for (int y = Math.Min(y1, y2); y <= Math.Max(y1, y2); y++)
                        {
                            map[x, y] += 1;
                        }
                    }
                }
                else if (considerDiagonals)
                {
                    int xStep = x1 < x2 ? 1 : -1;
                    int yStep = y1 < y2 ? 1 : -1;
                    int count = Math.Abs(x1 - x2);

                    for (int i = 0; i <= count; i++)
                    {
                        int currX = x1 + i * xStep;
                        int currY = y1 + i * yStep;

                        map[currX, currY] += 1;
                    }
                }
            }

            int result = 0;

            for (int x = 0; x < map.GetLength(0); x++)
            {
                for (int y = 0; y < map.GetLength(1); y++)
                {
                    if (map[x, y] >= 2)
                    {
                        result++;
                    }
                }
            }

            return result;
        }
    }
}
