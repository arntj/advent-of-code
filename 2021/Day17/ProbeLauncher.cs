namespace Day17
{
    public static class ProbeLauncher
    {
        public static int LaunchProbe(string input)
        {
            string[] coords = input.Substring("target area: ".Length).Split(",");

            string[] yCoords = coords[1].Trim().Substring(2).Split("..");
            int yMin = yCoords.Select(int.Parse).Min();

            return yMin * (yMin + 1) / 2;
        }

        public static int FindAllTrajectories(string input)
        {
            string[] coords = input.Substring("target area: ".Length).Split(",");

            string[] xCoords = coords[0].Trim().Substring(2).Split("..");
            int xMax = xCoords.Select(int.Parse).Max();
            int xMin = xCoords.Select(int.Parse).Min();

            string[] yCoords = coords[1].Trim().Substring(2).Split("..");
            int yMax = yCoords.Select(int.Parse).Max();
            int yMin = yCoords.Select(int.Parse).Min();

            // Create an index of n number of steps and what y velocity they are associated with
            Dictionary<int, List<int>> yTargetHits = new();

            for (int initialYVelocity = yMin; initialYVelocity <= -yMin - 1; initialYVelocity++)
            {
                int yVelocity = initialYVelocity;
                int y = 0;
                int n = 0;

                while (y >= yMin)
                {
                    if (y <= yMax)
                    {
                        if (yTargetHits.ContainsKey(n))
                        {
                            yTargetHits[n].Add(initialYVelocity);
                        }
                        else
                        {
                            yTargetHits[n] = new List<int> { initialYVelocity };
                        }
                    }

                    n++;
                    y += yVelocity;
                    yVelocity--;
                }
            }

            HashSet<(int x, int y)> initialVelocities = new();
            int maxN = yTargetHits.Keys.Max();

            for (int initialXVelocity = 1; initialXVelocity <= xMax; initialXVelocity++)
            {
                int xVelocity = initialXVelocity;
                int x = 0;
                int n = 0;

                while (x <= xMax)
                {
                    if (x >= xMin)
                    {
                        if (yTargetHits.ContainsKey(n))
                        {
                            foreach (int initialYVelocity in yTargetHits[n])
                            {
                                initialVelocities.Add((initialXVelocity, initialYVelocity));
                            }
                        }

                        if (xVelocity == 0)
                        {
                            for (int nn = n + 1; nn <= maxN; nn++)
                            {
                                if (yTargetHits.ContainsKey(nn))
                                {
                                    foreach (int initialYVelocity in yTargetHits[nn])
                                    {
                                        initialVelocities.Add((initialXVelocity, initialYVelocity));
                                    }
                                }
                            }
                            break;
                        }
                    }
                    else if (xVelocity == 0)
                    {
                        break;
                    }

                    n++;
                    x += xVelocity;
                    xVelocity = Math.Max(0, xVelocity - 1);
                }
            }

            return initialVelocities.Count;
        }
    }
}
