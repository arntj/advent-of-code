using MathNet.Numerics.LinearAlgebra;
using MathNet.Spatial.Euclidean;
using MathNet.Spatial.Units;

namespace Day19
{
    public static class BeaconMapper
    {
        public static (int numberOfBeacons, int maxDistanceBetweenScanners) CountTotalBeacons(string[] input)
        {
            List<List<(int x, int y, int z)>> scannersAndBeacons = new();
            List<(int x, int y, int z)> currBeacons = new();

            foreach (string line in input.Skip(1))
            {
                if (line.StartsWith("---"))
                {
                    scannersAndBeacons.Add(currBeacons);
                    currBeacons = new();
                    continue;
                }

                if (line.Trim().Length == 0)
                {
                    continue;
                }

                var parts = line.Split(',').Select(int.Parse).ToArray();
                currBeacons.Add((x: parts[0], y: parts[1], z: parts[2]));
            }

            scannersAndBeacons.Add(currBeacons);

            List<(int x, int y, int z)> distances = new();
            distances.Add((0, 0, 0));

            var rotationMatrices = GetRotationMatrices();

            while (scannersAndBeacons.Count > 1)
            {
                bool foundMatch = false;

                for (int i = 0; (!foundMatch) && i < scannersAndBeacons.Count; i++)
                {
                    for (int j = 0; (!foundMatch) && j < scannersAndBeacons.Count; j++)
                    {
                        if (i == j)
                        {
                            continue;
                        }

                        foreach (var rotation in rotationMatrices)
                        {
                            Dictionary<(int x, int y, int z), int> diffs = new();
                            var rotatedBeacons = scannersAndBeacons[j].Select(coord => ApplyMatrix(coord, rotation));

                            foreach (var b1 in scannersAndBeacons[i])
                            {
                                foreach (var b2 in rotatedBeacons)
                                {
                                    var diff = Subtract(b1, b2);

                                    if (diffs.ContainsKey(diff))
                                    {
                                        diffs[diff]++;
                                    }
                                    else
                                    {
                                        diffs[diff] = 1;
                                    }
                                }
                            }

                            var maxAtSameDiff = diffs.Values.Max();

                            if (maxAtSameDiff >= 12)
                            {
                                var d = diffs.First(kvp => kvp.Value == maxAtSameDiff).Key;

                                var translatedBeacons = rotatedBeacons.Select(b => Add(b, d));
                                HashSet<(int x, int y, int z)> joinedBeacons = new(scannersAndBeacons[i]);
                                joinedBeacons.UnionWith(translatedBeacons);

                                scannersAndBeacons[i] = joinedBeacons.ToList();
                                scannersAndBeacons.RemoveAt(j);

                                distances.Add(d);

                                foundMatch = true;
                                break;
                            }
                        }
                    }
                }
            }

            int maxDistance = 0;

            for (int i = 0; i < distances.Count - 1; i++)
            {
                for (int j = 1; j < distances.Count; j++)
                {
                    if (i == j)
                    {
                        continue;
                    }

                    maxDistance = Math.Max(maxDistance, ManhattanDistance(distances[i], distances[j]));
                }
            }

            return (scannersAndBeacons[0].Count, maxDistance);
        }

        public static int ManhattanDistance((int x, int y, int z) b1, (int x, int y, int z) b2)
        {
            return Math.Abs(b1.x - b2.x) + Math.Abs(b1.y - b2.y) + Math.Abs(b1.z - b2.z);
        }

        public static (int x, int y, int z) Subtract((int x, int y, int z) b1, (int x, int y, int z) b2)
        {
            return (b1.x - b2.x, b1.y - b2.y, b1.z - b2.z);
        }

        public static (int x, int y, int z) Add((int x, int y, int z) b1, (int x, int y, int z) b2)
        {
            return (b1.x + b2.x, b1.y + b2.y, b1.z + b2.z);
        }

        public static (int x, int y, int z) VectorToTuple(Vector<double> vec)
        {
            return (Convert.ToInt32(vec[0] + 0.2), Convert.ToInt32(vec[1] + 0.2), Convert.ToInt32(vec[2] + 0.2));
        }

        public static Vector<double> TupleToVector((int x, int y, int z) t)
        {
            return Vector<double>.Build.DenseOfArray(new double[] { t.x, t.y, t.z, 1 });
        }

        public static (int x, int y, int z) ApplyMatrix((int x, int y, int z) coords, Matrix<double> matrix)
        {
            var vector = TupleToVector(coords);

            var transformed = matrix * vector;

            var result = VectorToTuple(transformed);

            return result;
        }

        public static IEnumerable<Matrix<double>> GetRotationMatrices()
        {
            var ident = Matrix<double>.Build.DenseIdentity(4, 4);
            
            var x90 = From3DTo4DMatrix(Matrix3D.RotationAroundXAxis(Angle.FromDegrees(90)));
            var x180 = From3DTo4DMatrix(Matrix3D.RotationAroundXAxis(Angle.FromDegrees(180)));
            var x270 = From3DTo4DMatrix(Matrix3D.RotationAroundXAxis(Angle.FromDegrees(270)));

            var y90 = From3DTo4DMatrix(Matrix3D.RotationAroundYAxis(Angle.FromDegrees(90)));
            var y180 = From3DTo4DMatrix(Matrix3D.RotationAroundYAxis(Angle.FromDegrees(180)));
            var y270 = From3DTo4DMatrix(Matrix3D.RotationAroundYAxis(Angle.FromDegrees(270)));

            var z90 = From3DTo4DMatrix(Matrix3D.RotationAroundZAxis(Angle.FromDegrees(90)));
            var z180 = From3DTo4DMatrix(Matrix3D.RotationAroundZAxis(Angle.FromDegrees(180)));
            var z270 = From3DTo4DMatrix(Matrix3D.RotationAroundZAxis(Angle.FromDegrees(270)));

            yield return ident;
            yield return z90;
            yield return z180;
            yield return z270;

            yield return x90;
            yield return x90 * y90;
            yield return x90 * y180;
            yield return x90 * y270;

            yield return x180;
            yield return x180 * z90;
            yield return x180 * z180;
            yield return x180 * z270;

            yield return x270;
            yield return x270 * y90;
            yield return x270 * y180;
            yield return x270 * y270;

            yield return y90;
            yield return y90 * x90;
            yield return y90 * x180;
            yield return y90 * x270;

            yield return y270;
            yield return y270 * x90;
            yield return y270 * x180;
            yield return y270 * x270;
        }

        public static Matrix<double> From3DTo4DMatrix(Matrix<double> matrix)
        {
            var supermatrix = Matrix<double>.Build.DenseIdentity(4, 4);
            supermatrix.SetSubMatrix(0, 0, matrix);
            return supermatrix;
        }

        public static Matrix<double> CreateTranslationMatrix((int dx, int dy, int dz) t)
        {
            var matrix = Matrix<double>.Build.DenseIdentity(4, 4);

            matrix[0, 3] = t.dx;
            matrix[1, 3] = t.dy;
            matrix[2, 3] = t.dz;

            return matrix;
        }
    }
}
