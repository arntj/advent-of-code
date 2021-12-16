using System.Text;

namespace Day16
{
    public record Package(int Version, int Type, long? Value, List<Package> SubPackages);

    public static class BitsParser
    {
        public static long Execute(Package rootPackage)
        {
            var subPackageResult = rootPackage.SubPackages.Select(Execute).ToList();

            return rootPackage.Type switch
            {
                0 => rootPackage.SubPackages.Select(Execute).Sum(),
                1 => rootPackage.SubPackages.Select(Execute).Aggregate(1L, (acc, val) => acc * val),
                2 => rootPackage.SubPackages.Select(Execute).Min(),
                3 => rootPackage.SubPackages.Select(Execute).Max(),
                4 => rootPackage.Value ?? throw new ArgumentNullException(nameof(rootPackage.Value)),
                5 => Execute(rootPackage.SubPackages[0]) > Execute(rootPackage.SubPackages[1]) ? 1 : 0,
                6 => Execute(rootPackage.SubPackages[0]) < Execute(rootPackage.SubPackages[1]) ? 1 : 0,
                7 => Execute(rootPackage.SubPackages[0]) == Execute(rootPackage.SubPackages[1]) ? 1 : 0,
                _ => throw new NotImplementedException()
            };
        }

        public static Package Parse(string code)
        {
            string bits = HexToBinary(code);

            Package package;
            ParseData(bits, out package);

            return package;
        }

        public static int SumVersions(params Package[] packages)
        {
            return packages.Sum(p => p.Version + SumVersions(p.SubPackages.ToArray()));
        }

        private static int ParseData(string bits, out Package package, int start = 0)
        {
            int i = start;
            int version = BitsToInt(bits, i, 3);
            i += 3;
            int type = BitsToInt(bits, i, 3);
            i += 3;

            if (type == 4)
            {
                string data = "";

                do
                {
                    data += bits.Substring(i + 1, 4);
                    i += 5;
                }
                while (bits[i - 5] == '1');

                long value = Convert.ToInt64(data, 2);

                package = new Package(version, type, value, new());
            }
            else
            {
                List<Package> subPackages = new();

                if (bits[i] == '0')
                {
                    int length = BitsToInt(bits, i + 1, 15);
                    i += 16;
                    int end = i + length;

                    while (i < end)
                    {
                        Package currentPackage;
                        i = ParseData(bits, out currentPackage, i);
                        subPackages.Add(currentPackage);
                    }
                }
                else
                {
                    int count = BitsToInt(bits, i + 1, 11);
                    i += 12;
                    
                    for (int c = 0; c < count; c++)
                    {
                        Package currentPackage;
                        i = ParseData(bits, out currentPackage, i);
                        subPackages.Add(currentPackage);
                    }
                }

                package = new Package(version, type, null, subPackages);
            }

            return i;
        }

        private static string HexToBinary(string str)
        {
            StringBuilder stringBuilder = new();

            for (int i = 0; i < str.Length; i += 2)
            {
                string hex = str.Substring(i, 2);
                string b = Convert.ToString(Convert.ToInt32(hex, 16), 2).PadLeft(8, '0');
                stringBuilder.Append(b);
            }

            return stringBuilder.ToString();
        }

        private static int BitsToInt(string bits, int start, int length)
        {
            return Convert.ToInt32(bits.Substring(start, length), 2);
        }
    }
}
