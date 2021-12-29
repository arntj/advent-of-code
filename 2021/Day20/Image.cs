using System.Diagnostics;
using System.Text;

namespace Day20
{
    [DebuggerDisplay($"{{{nameof(ToString)}(),nq}}")]
    public class Image
    {
        private HashSet<(int x, int y)> _points;
        private int _minX;
        private int _maxX;
        private int _minY;
        private int _maxY;
        private bool _infinityValue;
        private readonly bool[] _algorithm;

        public Image(string[] input)
        {
            _algorithm = input[0].Select(val => val == '#').ToArray();
            _points = new();

            string[] map = input.Skip(2).ToArray();

            _minX = 1;
            _minY = 1;
            _maxY = map.Length;

            for (int i = 0; i < map.Length; i++)
            {
                int y = map.Length - i;

                _maxX = map[i].Length;

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
            bool nextInfinityValue = _infinityValue ? _algorithm[511] : _algorithm[0];
            int nextMinX = _minX;
            int nextMaxX = _maxX;
            int nextMinY = _minY;
            int nextMaxY = _maxY;

            var nextPoints = new HashSet<(int x, int y)>();

            for (int y = _minY - 3; y <= _maxY + 3; y++)
            {
                for (int x = _minX - 3; x <= _maxX + 3; x++)
                {
                    bool actualValue = GetEnhancedValue(x, y);

                    if (actualValue ^ nextInfinityValue)
                    {
                        nextPoints.Add((x, y));

                        nextMinX = Math.Min(x, nextMinX);
                        nextMaxX = Math.Max(x, nextMaxX);
                        nextMinY = Math.Min(y, nextMinY);
                        nextMaxY = Math.Max(y, nextMaxY);
                    }
                }
            }

            _infinityValue = nextInfinityValue;
            _points = nextPoints;
            _minX = nextMinX;
            _maxX = nextMaxX;
            _minY = nextMinY;
            _maxY = nextMaxY;
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

                index += actualValue ? Convert.ToInt32(Math.Pow(2, ex)) : 0;
            }

            return _algorithm[index];
        }

        public override string ToString()
        {
            StringBuilder output = new();

            for (int y = _maxY; y >= _minY; y--)
            {
                for (int x = _minX; x <= _maxX; x++)
                {
                    bool val = _points.Contains((x, y)) ^ _infinityValue;

                    output.Append(val ? "#" : ".");
                }

                output.AppendLine();
            }

            return output.ToString();
        }

        public int PointsCount => _points.Count;
    }
}
