namespace Day21
{
    public static class DiracDiceGame
    {
        public static int[] ParseInput(string[] input)
        {
            return new[]
            {
                int.Parse(input[0]["Player 1 starting position: ".Length..]),
                int.Parse(input[1]["Player 2 starting position: ".Length..])
            };
        }

        public static int PlayDeterministic(string[] input)
        {
            DeterministicDice dice = new();

            int[] playerSlots = ParseInput(input);
            int[] playerScores = new[] { 0, 0 };
            int i = 0;

            while (!playerScores.Any(v => v >= 1000))
            {
                int val = playerSlots[i];

                int diceThrow = dice.Throw();

                val = (val + diceThrow) % 10;

                if (val == 0)
                {
                    val = 10;
                }

                playerScores[i] += val;
                playerSlots[i] = val;

                i = (i + 1) % 2;
            }

            return dice.NumberOfThrows * Math.Min(playerScores[0], playerScores[1]);
        }

        public static long PlayDirac(string[] input)
        {
            int[] playerSlots = ParseInput(input);
            int[] initialScores = new[] { 0, 0 };

            Stack<(int[] slot, int[] score, long numberOfUniverses, int playerIndex)> universes = new();

            long[] victories = new[] { 0L, 0L };

            universes.Push((playerSlots, initialScores, 1, 0));

            while (universes.Count > 0)
            {
                (int[] slot, int[] score, long numberOfUniverses, int playerIndex) = universes.Pop();

                foreach ((int sumOfThrows, int numberOfThrowSequences) in GetPossibleThrowCombinations())
                {
                    long nextNumberOfUniverses = numberOfUniverses * numberOfThrowSequences;

                    int[] nextSlot = slot.ToArray();
                    nextSlot[playerIndex] += sumOfThrows;

                    while (nextSlot[playerIndex] > 10)
                    {
                        nextSlot[playerIndex] -= 10;
                    }

                    int[] nextScore = score.ToArray();
                    nextScore[playerIndex] += nextSlot[playerIndex];

                    if (nextScore[playerIndex] >= 21)
                    {
                        victories[playerIndex] += nextNumberOfUniverses;
                    }
                    else
                    {
                        int nextPlayerIndex = (playerIndex + 1) % 2;

                        universes.Push((nextSlot, nextScore, nextNumberOfUniverses, nextPlayerIndex));
                    }
                }
            }

            return Math.Max(victories[0], victories[1]);
        }

        private static (int score, int n)[] GetPossibleThrowCombinations()
        {
            return new[]
            {
                (score: 3, n: 1),
                (score: 4, n: 3),
                (score: 5, n: 6),
                (score: 6, n: 7),
                (score: 7, n: 6),
                (score: 8, n: 3),
                (score: 9, n: 1)
            };
        }
    }
}
