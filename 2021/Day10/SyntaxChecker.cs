namespace Day10
{
    public static class SyntaxChecker
    {
        public static int CalculateErrorScore(string[] input)
        {
            return input
                .Select(CheckLine)
                .Select(result => result.illegalCloser switch
                {
                    null => 0,
                    ')' => 3,
                    ']' => 57,
                    '}' => 1197,
                    '>' => 25137,
                    _ => throw new ArgumentOutOfRangeException(result.illegalCloser.Value.ToString())
                })
                .Sum();
        }
        
        public static long CalculateCompletionScore(string[] input)
        {
            var orderedScores = input
                .Select(CheckLine)
                .Where(result => result.illegalCloser == null)
                .Select(result => CalculateCompletionScoreForLine(result.unclosedCharacters))
                .OrderByDescending(x => x);

            return orderedScores.ElementAt(orderedScores.Count() / 2);
        }

        private static long CalculateCompletionScoreForLine(char[] unclosedCharacters)
        {
            return unclosedCharacters
                .Select(c => c switch
                {
                    '(' => 1,
                    '[' => 2,
                    '{' => 3,
                    '<' => 4,
                    _ => throw new ArgumentOutOfRangeException(c.ToString())
                })
                .Aggregate((long)0, (sum, c) => sum * 5 + c);
        }

        private static (char[] unclosedCharacters, char? illegalCloser) CheckLine(string line)
        {
            Stack<char> delimiters = new();
            char[] openers = new[] { '(', '[', '{', '<' };
            char[] closers = new[] { ')', ']', '}', '>' };

            foreach (char c in line)
            {
                if (openers.Contains(c))
                {
                    delimiters.Push(c);
                    continue;
                }

                int index = Array.IndexOf(closers, c);

                if (index >= 0)
                {
                    if (delimiters.Pop() != openers[index])
                    {
                        return (delimiters.ToArray(), c);
                    }
                }
            }

            return (delimiters.ToArray(), null);
        }
    }
}
