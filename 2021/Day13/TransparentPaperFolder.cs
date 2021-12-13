namespace Day13
{
    public static class TransparentPaperFolder
    {
        public static int FoldOnce(string[] input)
        {
            HashSet<(int x, int y)> dots = ParseDots(input);

            string foldInstruction = input.SkipWhile(line => line.Length > 0).Skip(1).First();

            Fold(dots, foldInstruction);

            return dots.Count();
        }

        public static void FoldAll(string[] input)
        {
            HashSet<(int x, int y)> dots = ParseDots(input);

            var foldInstructions = input.SkipWhile(line => line.Length > 0).Skip(1);

            foreach(string instruction in foldInstructions)
            {
                Fold(dots, instruction);
            }

            DrawDots(dots);
        }

        private static HashSet<(int x, int y)> ParseDots(string[] input)
        {
            HashSet<(int x, int y)> dots = new();
            
            int c = 0;
            while (input[c].Trim().Length > 0)
            {
                string[] parts = input[c].Split(',');
                var currDot = (int.Parse(parts[0]), int.Parse(parts[1]));
                dots.Add(currDot);

                ++c;
            }

            return dots;
        }

        private static void Fold(HashSet<(int x, int y)> dots, string foldInstruction)
        {
            string curr = foldInstruction["fold along ".Length..];
            int foldAt = int.Parse(curr[2..]);
            bool foldAtX = curr.StartsWith("x");

            var currentDots = dots.ToArray();

            foreach (var dot in currentDots)
            {
                if ((foldAtX && dot.x > foldAt) || (!foldAtX && dot.y > foldAt))
                {
                    dots.Remove(dot);

                    int x = foldAtX ? 2 * foldAt - dot.x : dot.x;
                    int y = !foldAtX ? 2 * foldAt - dot.y : dot.y;

                    dots.Add((x, y));
                }
            }
        }

        private static void DrawDots(HashSet<(int x, int y)> dots)
        {
            int maxX = dots.Select(d => d.x).Max();
            int maxY = dots.Select(d => d.y).Max();

            for (int y = 0; y <= maxY; y++)
            {
                for (int x = 0; x <= maxX; x++)
                {
                    bool hasDot = dots.Contains((x, y));

                    Console.Write(hasDot ? "#" : " ");
                }
                Console.WriteLine();
            }
            Console.WriteLine();
        }
    }
}
