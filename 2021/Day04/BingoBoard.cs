namespace Day04
{
    public class BingoBoard
    {
        private readonly List<int> numbers;
        private readonly HashSet<int> drawnNumbers = new HashSet<int>();

        public BingoBoard(IEnumerable<int> numbers)
        {
            if (numbers.Count() != 25)
            {
                throw new ArgumentException(nameof(numbers));
            }

            this.numbers = numbers.ToList();
        }

        public void MarkNumber(int n)
        {
            drawnNumbers.Add(n);
        }

        public IEnumerable<int> GetUnmarkedNumbers()
        {
            return numbers.Where(n => !drawnNumbers.Contains(n));
        }

        public bool HasBingo()
        {
            for (int i = 0; i < 5; i++)
            {
                // check row
                var row = numbers.Skip(i * 5).Take(5);
                if (row.All(drawnNumbers.Contains))
                {
                    return true;
                }

                // check column
                var column = numbers.Skip(i).Where((x, i) => i % 5 == 0);
                if (column.All(drawnNumbers.Contains))
                {
                    return true;
                }
            }

            return false;
        }
    }
}
