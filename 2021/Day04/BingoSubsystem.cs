namespace Day04
{
    public static class BingoSubsystem
    {
        public static (int firstScore, int lastScore) PlayBingo(string[] lines)
        {
            IEnumerable<int> numbersToDraw = lines[0].Split(',').Select(int.Parse);

            int currPos = 2;
            List<BingoBoard> boards = new List<BingoBoard>();

            while (currPos < lines.Length)
            {
                IEnumerable<int> boardNumbers = Enumerable
                    .Range(currPos, 5)
                    .SelectMany(i => lines[i].Split(" ", StringSplitOptions.RemoveEmptyEntries))
                    .Select(int.Parse);
                boards.Add(new BingoBoard(boardNumbers));
                currPos += 6;
            }

            bool firstWin = false;
            int firstScore = 0, lastScore = 0;

            foreach (int n in numbersToDraw)
            {
                foreach(var board in boards)
                {
                    board.MarkNumber(n);

                    if (board.HasBingo())
                    {
                        if (!firstWin)
                        {
                            firstWin = true;
                            firstScore = n * board.GetUnmarkedNumbers().Sum();
                        }
                        
                        lastScore = n * board.GetUnmarkedNumbers().Sum();
                    }
                }

                boards.RemoveAll(b => b.HasBingo());
            }

            return (firstScore, lastScore);
        }
    }
}
