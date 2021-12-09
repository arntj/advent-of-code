namespace Day09
{
    public static class HeightMapSeeker
    {
        public static int FindLowPoints(string[] data)
        {
            int rows = data.Length;
            int cols = data[0].Length;
            int result = 0;

            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    bool lowPoint =
                        (data[i][j] < '9')
                        && (j == 0 || data[i][j] < data[i][j - 1])
                        && (j == cols - 1 || data[i][j] < data[i][j + 1])
                        && (i == 0 || data[i][j] < data[i - 1][j])
                        && (i == rows - 1 || data[i][j] < data[i + 1][j]);

                    if (lowPoint)
                    {
                        result += (data[i][j] - '0') + 1;
                    }
                }
            }

            return result;
        }

        public static int FindBasins(string[] data)
        {
            int rows = data.Length;
            int cols = data[0].Length;
            int[,] input = new int[rows, cols];

            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    input[i, j] = int.Parse(data[i][j] + "");
                }
            }

            List<int> basinSizes = new List<int>();

            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    int currData = input[i, j];

                    if (-1 < currData && currData < 9)
                    {
                        basinSizes.Add(MarkBasin(input, i, j));
                    }
                }
            }

            return basinSizes.OrderByDescending(x => x).Take(3).Aggregate(1, (int acc, int x) => acc * x);
        }

        private static int MarkBasin(int[,] data, int i, int j)
        {
            if (data[i, j] < 0 || data[i, j] == 9)
            {
                return 0;
            }

            int count = 0;

            data[i, j] = -1;
            count += 1;

            if (i > 0)
            {
                count += MarkBasin(data, i - 1, j);
            }
            if (i < data.GetLength(0) - 1)
            {
                count += MarkBasin(data, i + 1, j);
            }
            if (j > 0)
            {
                count += MarkBasin(data, i, j - 1);
            }
            if (j < data.GetLength(1) - 1)
            {
                count += MarkBasin(data, i, j + 1);
            }

            return count;
        }
    }
}
