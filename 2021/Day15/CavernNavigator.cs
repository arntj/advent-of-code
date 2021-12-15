namespace Day15
{
    public static class CavernNavigator
    {
        public static int FindShortestPath(string[] input, int caveSizeFactor)
        {
            int xLength = input[0].Length * caveSizeFactor;
            int yLength = input.Length * caveSizeFactor;

            int[][] riskLevels = new int[yLength][];

            for (int y = 0; y < yLength; y++)
            {
                int[] line = new int[xLength];

                for (int x = 0; x < xLength; x++)
                {
                    int inputX = x % input[0].Length;
                    int inputY = y % input.Length;

                    // find and convert number from char to int
                    int num = input[inputY][inputX] - '0';

                    // add repetition multiple in x and y direction
                    num += (y / input.Length) + (x / input[0].Length);

                    // 9 should wrap back to 1
                    num = (num - 1) % 9 + 1;

                    line[x] = num;
                }

                riskLevels[y] = line;
            }

            int[][] minRisks = new int[yLength][];

            for (int i = 0; i < yLength; i++)
            {
                minRisks[i] = Enumerable.Repeat(int.MaxValue, xLength).ToArray();
            }

            minRisks[0][0] = 0;

            PriorityQueue<(int x, int y), int> queue = new();
            queue.Enqueue((0, 0), 0);

            while (queue.Count > 0)
            {
                var curr = queue.Dequeue();
                var risk = minRisks[curr.y][curr.x];

                // iterate over the four neighbours
                foreach ((int dx, int dy) in new[] {(-1, 0), (0, -1), (1, 0), (0, 1)})
                {
                    int x = curr.x + dx;
                    int y = curr.y + dy;

                    if (x < 0 || y < 0 || x >= xLength || y >= yLength)
                    {
                        continue;
                    }

                    int newRisk = risk + riskLevels[y][x];

                    if (newRisk < minRisks[y][x])
                    {
                        minRisks[y][x] = newRisk;
                        queue.Enqueue((x, y), newRisk);
                    }
                }
            }

            return minRisks[yLength - 1][xLength - 1];            
        }
    }
}
