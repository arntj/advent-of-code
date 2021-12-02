using System.Text.RegularExpressions;

namespace Day02
{
    public static class SubmarineNavigator
    {
        public static (int pos, int aim, int depth) ParseDirections(string[] directions)
        {
            return directions.Aggregate<string, (int pos, int aim, int depth)>(
                (0, 0, 0),
                (acc, curr) =>
                {
                    var match = Regex.Match(curr, @"^(.*) (\d+)");

                    if (!match.Success)
                    {
                        throw new ArgumentException($"Couldn't interpret direction: '{curr}'");
                    }

                    string direction = match.Groups[1].Value;
                    int n = int.Parse(match.Groups[2].Value);

                    if (direction == "forward")
                    {
                        return (acc.pos + n, acc.aim, acc.depth += acc.aim * n);
                    }
                    if (direction == "up")
                    {
                        return (acc.pos, acc.aim - n, acc.depth);
                    }
                    if (direction == "down")
                    {
                        return (acc.pos, acc.aim + n, acc.depth);
                    }

                    throw new ArgumentException($"Couldn't interpret direction: '{curr}'");
                }
            );
        }
    }
}
