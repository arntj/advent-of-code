namespace Day22
{
    public record ReactorCube(long X1, long X2, long Y1, long Y2, long Z1, long Z2)
    {
        public long Cubes => (X2 - X1) * (Y2 - Y1) * (Z2 - Z1);

        public IEnumerable<ReactorCube> Subtract(ReactorCube other)
        {
            if (!Overlap(other))
            {
                yield return this;
                yield break;
            }

            if (Z2 > other.Z2)
            {
                // return part that is above other cube
                yield return new ReactorCube(X1, X2, Y1, Y2, other.Z2, Z2);
            }

            if (Z1 < other.Z1)
            {
                // return part that is below other cube
                yield return new ReactorCube(X1, X2, Y1, Y2, Z1, other.Z1);
            }

            if (X1 < other.X1)
            {
                // return part that is behind other cube
                yield return new ReactorCube(X1, other.X1, Y1, Y2, Math.Max(Z1, other.Z1), Math.Min(Z2, other.Z2));
            }

            if (X2 > other.X2)
            {
                // return part that is in front of other cube
                yield return new ReactorCube(other.X2, X2, Y1, Y2, Math.Max(Z1, other.Z1), Math.Min(Z2, other.Z2));
            }            

            if (Y1 < other.Y1)
            {
                // return part that is on one side of other cube
                yield return new ReactorCube(Math.Max(X1, other.X1), Math.Min(X2, other.X2), Y1, other.Y1, Math.Max(Z1, other.Z1), Math.Min(Z2, other.Z2));
            }

            if (Y2 > other.Y2)
            {
                // return part that is on other side of other cube
                yield return new ReactorCube(Math.Max(X1, other.X1), Math.Min(X2, other.X2), other.Y2, Y2, Math.Max(Z1, other.Z1), Math.Min(Z2, other.Z2));
            }
        }

        private static bool CoordinatesOverlap(long a1, long a2, long b1, long b2)
        {
            return (a1 < b2) && (a2 > b1);
        }

        public bool Overlap(ReactorCube a)
        {
            return CoordinatesOverlap(X1, X2, a.X1, a.X2)
                && CoordinatesOverlap(Y1, Y2, a.Y1, a.Y2)
                && CoordinatesOverlap(Z1, Z2, a.Z1, a.Z2);
        }
    }
}
