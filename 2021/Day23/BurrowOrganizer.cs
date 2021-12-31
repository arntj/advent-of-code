namespace Day23
{
    public static class BurrowOrganizer
    {
        public static string[] InsertExtraRows(string[] input)
        {
            var list = input.ToList();
            list.Insert(3, "  #D#C#B#A#");
            list.Insert(4, "  #D#B#A#C#");

            return list.ToArray();
        }

        public static int Organize(string[] input)
        {
            PriorityQueue<string[], int> states = new();
            Dictionary<string, int> seenStates = new();

            states.Enqueue(input, 0);

            while (states.TryDequeue(out string[]? state, out int energy))
            {
                if (state == null)
                {
                    throw new InvalidOperationException($"{nameof(state)} is null");
                }

                if (AllHome(state))
                {
                    return energy;
                }

                string index = GetIndex(state);
                if (seenStates.ContainsKey(index) && seenStates[index] <= energy)
                {
                    continue;
                }
                seenStates[index] = energy;

                foreach ((string[] nextState, int nextEnergy) in GetValidMoves(state, energy))
                {
                    states.Enqueue(nextState, nextEnergy);
                }
            }

            throw new Exception("Unsolvable");
        }

        public static bool AllHome(string[] state)
        {
            for (int i = 2; i < state.Length - 1; i++)
            {
                if (state[i].Trim().Trim('#') != "A#B#C#D")
                {
                    return false;
                }
            }

            return true;
        }

        public static IEnumerable<(string[] state, int energy)> GetValidMoves(string[] state, int energy)
        {
            // Check hallway for amphipods that can move home
            for (int i = 1; i < 12; i++)
            {
                char currVal = state[1][i];

                if (currVal >= 'A' && currVal <= 'D')
                {
                    int homeCol = _homeCols[currVal - 'A'];
                    int pathHomeStart = Math.Min(i + 1, homeCol);
                    int pathHomeEnd = Math.Max(homeCol, i - 1);
                    string pathHome = state[1].Substring(pathHomeStart, pathHomeEnd - pathHomeStart + 1);

                    bool canMoveHome = pathHome.All(c => c == '.') && state[2][homeCol] == '.';
                    int moveToRow = 2;

                    for (int j = 3; j < state.Length - 1; j++)
                    {
                        if (state[j][homeCol] == '.')
                        {
                            moveToRow = j;
                        }
                        else if (state[j][homeCol] != currVal)
                        {
                            canMoveHome = false;
                            break;
                        }
                    }

                    if (canMoveHome)
                    {
                        int steps = pathHome.Length + (moveToRow - 1);
                        int nextEnergy = energy + steps * GetEnergyNeed(currVal);

                        string[] nextState = Move(state, (i, 1), (homeCol, moveToRow));

                        yield return (nextState, nextEnergy);
                    }
                }
            }

            // Check rooms for amphipods that can move out
            for (char roomType = 'A'; roomType <= 'D'; roomType = (char)(roomType + 1))
            {
                int currCol = _homeCols[roomType - 'A'];
                bool hasWrongType = false;
                int moveFromRow = 2;

                for (int j = 2; j < state.Length - 1; j++)
                {
                    if (state[j][currCol] == '.')
                    {
                        moveFromRow = j + 1;
                    }
                    else if (state[j][currCol] != '.' && state[j][currCol] != roomType)
                    {
                        hasWrongType = true;
                        break;
                    }
                }

                if (hasWrongType)
                {
                    // look for movement options up and left
                    int j = currCol;
                    while (state[1][j] == '.')
                    {
                        if (!_homeCols.Contains(j))
                        {
                            int steps = currCol - j + (moveFromRow - 1);
                            int nextEnergy = energy + steps * GetEnergyNeed(state[moveFromRow][currCol]);

                            string[] nextState = Move(state, (currCol, moveFromRow), (j, 1));

                            yield return (nextState, nextEnergy);
                        }
                        j--;
                    }

                    // look for movement options up and right
                    j = currCol;
                    while (state[1][j] == '.')
                    {
                        if (!_homeCols.Contains(j))
                        {
                            int steps = j - currCol + (moveFromRow - 1);
                            int nextEnergy = energy + steps * GetEnergyNeed(state[moveFromRow][currCol]);

                            string[] nextState = Move(state, (currCol, moveFromRow), (j, 1));

                            yield return (nextState, nextEnergy);
                        }
                        j++;
                    }
                }
            }
        }

        private static string GetIndex(string[] state)
        {
            return string.Join("", state.Select(s => s.Trim()));
        }

        private static readonly int[] _homeCols = new[] { 3, 5, 7, 9 };

        private static string[] Move(string[] state, (int x, int y) from, (int x, int y) to)
        {
            string[] newState = (string[])state.Clone();
            newState[to.y] = newState[to.y].Remove(to.x, 1).Insert(to.x, state[from.y][from.x] + "");
            newState[from.y] = newState[from.y].Remove(from.x, 1).Insert(from.x, ".");

            return newState;
        }

        private static int GetEnergyNeed(char type)
        {
            int ex = type - 'A';
            int result = 1;

            while (ex > 0)
            {
                result *= 10;
                ex--;
            }

            return result;
        }
    }
}
