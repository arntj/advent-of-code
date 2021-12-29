namespace Day20
{
    public class Image
    {
        private HashSet<(int x, int y)> _points;
        private bool _infinityValue;
        private readonly bool[] _algorithm;

        public Image(string[] input)
        {
            _algorithm = input[0].Select(val => val == '#').ToArray();
            _points = new();

            string[] map = input.Skip(2).ToArray();

            for (int i = 0; i < map.Length; i++)
            {
                int y = map.Length - i;

                for (int j = 0; j < map[i].Length; j++)
                {
                    int x = j + 1;

                    if (map[i][j] == '#')
                    {
                        _points.Add((x, y));
                    }
                }
            }

            _infinityValue = false;
        }

        public void Enhance(int n)
        {
            while (n > 0)
            {
                Enhance();
                n--;
            }
        }

        private void Enhance()
        {
            bool nextInfinityValue = _infinityValue ? _algorithm[0b111_111_111] : _algorithm[0];
            int minX = int.MaxValue;
            int maxX = int.MinValue;
            int minY = int.MaxValue;
            int maxY = int.MinValue;

            foreach ((int x, int y) in _points)
            {
                minX = Math.Min(x, minX);
                maxX = Math.Max(x, maxX);
                minY = Math.Min(y, minY);
                maxY = Math.Max(y, maxY);
            }

            var nextPoints = new HashSet<(int x, int y)>();

            for (int y = minY - 2; y <= maxY + 2; y++)
            {
                for (int x = minX - 2; x <= maxX + 2; x++)
                {
                    bool actualValue = GetEnhancedValue(x, y);

                    if (actualValue ^ nextInfinityValue)
                    {
                        nextPoints.Add((x, y));
                    }
                }
            }

            _infinityValue = nextInfinityValue;
            _points = nextPoints;
        }

        private bool GetEnhancedValue(int x, int y)
        {
            int index = 0;

            for (int i = 0; i < 9; i++)
            {
                int currX = x + ((i % 3) - 1);
                int currY = y + 1 - (i / 3);
                int ex = 8 - i;

                bool actualValue = _points.Contains((currX, currY)) ^ _infinityValue;

                if (actualValue)
                {
                    index += 1 << ex;
                }
            }

            return _algorithm[index];
        }

        public int PointsCount => _points.Count;
    }
}
