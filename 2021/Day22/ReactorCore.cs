namespace Day22
{
    public class ReactorCore
    {
        private readonly HashSet<ReactorCube> _cubes = new();

        public void Parse(string[] rebootSteps)
        {
            foreach (string line in rebootSteps)
            {
                bool on = line.StartsWith("on");
                string[] values = line[(on ? 3 : 4)..].Split(",");

                long[] xrange = values[0][2..].Split("..").Select(long.Parse).ToArray();
                long[] yrange = values[1][2..].Split("..").Select(long.Parse).ToArray();
                long[] zrange = values[2][2..].Split("..").Select(long.Parse).ToArray();

                if (on)
                {
                    TurnOnCubes(xrange[0], xrange[1], yrange[0], yrange[1], zrange[0], zrange[1]);
                }
                else
                {
                    TurnOffCubes(xrange[0], xrange[1], yrange[0], yrange[1], zrange[0], zrange[1]);
                }
            }
        }

        public void TurnOnCubes(long x1, long x2, long y1, long y2, long z1, long z2)
        {
            // Remove any overlap so the same cubes don't get counted twice
            TurnOffCubes(x1, x2, y1, y2, z1, z2);

            _cubes.Add(new ReactorCube(x1 - 1, x2, y1 - 1, y2, z1 - 1, z2));
        }

        public void TurnOffCubes(long x1, long x2, long y1, long y2, long z1, long z2)
        {
            var offCube = new ReactorCube(x1 - 1, x2, y1 - 1, y2, z1 - 1, z2);

            foreach (var cube in _cubes.ToList())
            {
                if (cube.Overlap(offCube))
                {
                    _cubes.Remove(cube);

                    var newCubes = cube.Subtract(offCube);

                    _cubes.UnionWith(newCubes);
                }
            }
        }

        public long Cubes => _cubes.Sum(c => c.Cubes);

        public long GetInitializationCubesCount()
        {
            var initializationCube = new ReactorCube(-50, 50, -50, 50, -50, 50);

            return _cubes.Where(c => c.Overlap(initializationCube)).Sum(c => c.Cubes);
        }

        public long GetAllCubesCount()
        {
            return _cubes.Sum(c => c.Cubes);
        }
    }
}
