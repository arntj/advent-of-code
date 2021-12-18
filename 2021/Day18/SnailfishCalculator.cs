namespace Day18
{
    public interface ISnailfishNumber { }

    public record SnailfishValue : ISnailfishNumber
    {
        public SnailfishValue(int value)
        {
            Value = value;
        }

        public int Value { get; set; }
    }

    public record SnailfishPair : ISnailfishNumber
    {
        public SnailfishPair(ISnailfishNumber x, ISnailfishNumber y)
        {
            X = x;
            Y = y;
        }
        public SnailfishPair(int x, int y) : this(new SnailfishValue(x), new SnailfishValue(y)) { }

        public ISnailfishNumber X { get; set; }
        public ISnailfishNumber Y { get; set; }
    }

    public static class SnailfishCalculator
    {
        public static int LargestMagnitudeSum(string[] data)
        {
            int max = 0;

            for (int i = 0; i < data.Length; i++)
            {
                for (int j = 0; j < data.Length; j++)
                {
                    if (i == j)
                    {
                        continue;
                    }

                    var num1 = ParseValue(data[i], 0, out int _);
                    var num2 = ParseValue(data[j], 0, out int _);

                    var sum = Add(num1, num2);
                    var magnitude = Magnitude(sum);

                    max = Math.Max(max, magnitude);
                }
            }

            return max;
        }

        public static ISnailfishNumber Add(params ISnailfishNumber[] numbers)
        {
            if (numbers.Length == 0)
            {
                return new SnailfishValue(0);
            }

            var sum = numbers[0];

            for (int i = 1; i < numbers.Length; i++)
            {
                sum = new SnailfishPair(sum, numbers[i]);
                Reduce(sum);
            }

            return sum;
        }

        public static int Magnitude(ISnailfishNumber num)
        {
            if (num is SnailfishValue value)
            {
                return value.Value;
            }

            if (num is SnailfishPair pair)
            {
                return 3 * Magnitude(pair.X) + 2 * Magnitude(pair.Y);
            }

            throw new NotImplementedException();
        }

        public static void Reduce(ISnailfishNumber num)
        {
            while (Explode(num) || Split(num)) { }
        }

        public static bool Split(ISnailfishNumber num)
        {
            if (num is SnailfishValue)
            {
                return false;
            }

            Stack<(ISnailfishNumber number, SnailfishPair? parent)> stack = new();
            stack.Push((num, null));

            while (stack.Count > 0)
            {
                (var curr, var parent) = stack.Pop();

                if (curr is SnailfishValue value)
                {
                    if (value.Value >= 10)
                    {
                        int x = value.Value / 2;
                        int y = value.Value / 2 + value.Value % 2;

                        var newValue = new SnailfishPair(x, y);

                        if (parent?.X == curr)
                        {
                            parent.X = newValue;
                        }
                        else if (parent?.Y == curr)
                        {
                            parent.Y = newValue;
                        }
                        return true;
                    }
                }
                else if (curr is SnailfishPair pair)
                {
                    stack.Push((pair.Y, pair));
                    stack.Push((pair.X, pair));
                }
            }

            return false;
        }

        public static bool Explode(ISnailfishNumber num)
        {
            if (num is SnailfishValue)
            {
                return false;
            }

            Stack<(int level, ISnailfishNumber number, SnailfishPair? parent)> stack = new();
            stack.Push((1, num, null));

            SnailfishValue? lastValue = null;
            int? toMoveRight = null;

            while (stack.Count > 0)
            {
                (int level, var curr, var parent) = stack.Pop();

                if (curr is SnailfishPair pair)
                {
                    if (toMoveRight == null && level > 4 && pair.X is SnailfishValue x && pair.Y is SnailfishValue y)
                    {
                        if (lastValue != null)
                        {
                            lastValue.Value += x.Value;
                        }
                        toMoveRight = y.Value;

                        if (parent?.X == curr)
                        {
                            parent.X = new SnailfishValue(0);
                        }
                        else if (parent?.Y == curr)
                        {
                            parent.Y = new SnailfishValue(0);
                        }
                    }
                    else
                    {
                        stack.Push((level + 1, pair.Y, pair));
                        stack.Push((level + 1, pair.X, pair));
                    }
                }
                else if (curr is SnailfishValue value)
                {
                    if (toMoveRight != null)
                    {
                        value.Value += toMoveRight.Value;
                        return true;
                    }

                    lastValue = value;
                }
            }

            return toMoveRight != null;
        }

        public static List<ISnailfishNumber> ParseNumbers(string[] input)
        {
            return input.Select(line => ParseValue(line, 0, out int _)).ToList();
        }

        public static ISnailfishNumber ParseValue(string line, int start, out int i)
        {
            i = start;

            ISnailfishNumber x;
            ISnailfishNumber y;

            // move over opening bracket
            i++;

            if (line[i] == '[')
            {
                x = ParseValue(line, i, out i);
            }
            else
            {
                // convert char to int
                x = new SnailfishValue(line[i] - '0');
                i++;
            }

            if (line[i] != ',')
            {
                throw new ArgumentException($"Expected comma, got '{line[i]}' at position {i} of the line: '{line}'");
            }

            // move over comma
            i++;

            if (line[i] == '[')
            {
                y = ParseValue(line, i, out i);
            }
            else
            {
                // convert char to int
                y = new SnailfishValue(line[i] - '0');
                i++;
            }

            // move over closing bracket
            i++;

            return new SnailfishPair(x, y);
        }
    }
}
