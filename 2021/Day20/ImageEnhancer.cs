using System.Text;

namespace Day20
{
    public static class ImageEnhancer
    {
        public static (string image, string algorithm, char infiniteValue) ParseInput(string[] input)
        {
            return (string.Join('\n', input.Skip(2)), input[0], '.');
        }

        public static string ExtendImage(string input, char infiniteValue)
        {
            string[] lines = input.Split('\n');

            int x = lines[0].Length;
            int y = lines.Length;

            StringBuilder outputBuilder = new();

            for (int outY = 0; outY < y + 6; outY++)
            {
                for (int outX = 0; outX < x + 6; outX++)
                {
                    if (outX < 3 || outX >= x + 3 || outY < 3 || outY >= y + 3)
                    {
                        outputBuilder.Append(infiniteValue);
                        continue;
                    }

                    outputBuilder.Append(lines[outY - 3][outX - 3]);
                }
                if (outY < y + 5)
                {
                    outputBuilder.Append('\n');
                }
            }

            return outputBuilder.ToString();
        }

        public static int GetIndex(int x, int y, string input)
        {
            string[] lines = input.Split('\n');

            string data = lines[y - 1].Substring(x - 1, 3)
                + lines[y].Substring(x - 1, 3)
                + lines[y + 1].Substring(x - 1, 3);

            data = data.Replace('#', '1').Replace('.', '0');

            return Convert.ToInt32(data, 2);
        }

        public static char GetValue(int x, int y, string input, string algorithm)
        {
            int index = GetIndex(x, y, input);
            return algorithm[index];
        }

        public static (string image, char infiniteValue) Enhance(string input, string algorithm, char infiniteValue)
        {
            string extendedInput = ExtendImage(input, infiniteValue);
            string[] lines = extendedInput.Split('\n');
            char nextInfiniteValue = infiniteValue == '.' ? algorithm.First() : algorithm.Last();

            int x = lines[0].Length;
            int y = lines.Length;

            StringBuilder outputBuilder = new();

            for (int outY = 0; outY < y; outY++)
            {
                for (int outX = 0; outX < x; outX++)
                {
                    if (outX == 0 || outX == x - 1 || outY == 0 || outY == y - 1)
                    {
                        outputBuilder.Append(nextInfiniteValue);
                        continue;
                    }

                    char value = GetValue(outX, outY, extendedInput, algorithm);

                    outputBuilder.Append(value);
                }

                if (outY < y - 1)
                {
                    outputBuilder.Append('\n');
                }
            }

            return (outputBuilder.ToString(), nextInfiniteValue);
        }
    }
}
