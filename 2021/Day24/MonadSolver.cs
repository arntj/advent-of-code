namespace Day24
{
    public static class MonadSolver
    {
        public static string SolveForMax(string[] input) => Solve(input, true);
        public static string SolveForMin(string[] input) => Solve(input, false);

        private static string Solve(string[] input, bool findMax)
        {
            List<string[]> codeBlocks = SplitCodeBlocks(input);

            List<List<IAluInstruction>> instructions = new();
            List<Dictionary<(int w, int z), int>> memoizedZOut = new();
            List<HashSet<int>> alreadySeenOutputs = new();

            for (int i = 0; i < codeBlocks.Count; i++)
            {
                instructions.Add(Alu.Parse(codeBlocks[i]).ToList());
                memoizedZOut.Add(new());
                alreadySeenOutputs.Add(new());
            }

            Stack<(int i, int z, string solution)> stack = new();
            stack.Push((0, 0, ""));

            while (stack.TryPop(out var curr))
            {
                (int i, int z, string solution) = curr;

                if (i == instructions.Count)
                {
                    if (z == 0)
                    {
                        return solution;
                    }
                    continue;
                }

                int nextI = i + 1;

                int[] inputs = findMax ? _inputsForMax : _inputsForMin;

                foreach (int w in inputs)
                {
                    string nextSolution = solution + w;

                    int nextZ;
                    if (memoizedZOut[i].ContainsKey((w, z)))
                    {
                        nextZ = memoizedZOut[i][(w, z)];
                    }
                    else
                    {
                        nextZ = Alu.Execute(instructions[i], w, z);
                        memoizedZOut[i][(w, z)] = nextZ;
                    }

                    if (alreadySeenOutputs[i].Contains(nextZ))
                    {
                        continue;
                    }

                    alreadySeenOutputs[i].Add(nextZ);

                    stack.Push((nextI, nextZ, nextSolution));
                }
            }

            throw new Exception("unsolvable");
        }

        private static List<string[]> SplitCodeBlocks(string[] input)
        {
            List<string[]> codeBlocks = new();

            List<string> currBlock = new(input.Take(1));

            foreach (string line in input.Skip(1))
            {
                if (line.StartsWith("inp"))
                {
                    codeBlocks.Add(currBlock.ToArray());
                    currBlock = new();
                }

                currBlock.Add(line);
            }

            codeBlocks.Add(currBlock.ToArray());
            return codeBlocks;
        }

        private readonly static int[] _inputsForMax = new[] { 1, 2, 3, 4, 5, 6, 7, 8, 9 };
        private readonly static int[] _inputsForMin = new[] { 9, 8, 7, 6, 5, 4, 3, 2, 1 };
    }
}
