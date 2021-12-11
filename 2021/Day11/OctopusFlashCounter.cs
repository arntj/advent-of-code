namespace Day11
{
    public static class OctopusFlashCounter
    {
        public static int CountFlashes(string[] input, int steps)
        {
            int[,] octopusMap = ParseInput(input);

            int result = 0;

            //PrintMap(octopusMap);

            for (int n = 0; n < steps; n++)
            {
                result += RunStep(octopusMap);

                //PrintMap(octopusMap);
            }

            return result;
        }

        private static int[,] ParseInput(string[] input)
        {
            int[,] octopusMap = new int[input.Length, input[0].Length];

            for (int i = 0; i < input.Length; i++)
            {
                for (int j = 0; j < input[i].Length; j++)
                {
                    octopusMap[i, j] = input[i][j] - '0';
                }
            }

            return octopusMap;
        }

        public static int StepsBeforeAllFlash(string[] input)
        {
            int[,] octopusMap = ParseInput(input);
            int n = 1;

            while (RunStep(octopusMap) < octopusMap.Length)
            {
                n++;
            }

            return n;
        }

        private static int RunStep(int[,] octopusMap)
        {
            int flashes = 0;

            // increment all fields
            for (int i = 0; i < octopusMap.GetLength(0); i++)
            {
                for (int j = 0; j < octopusMap.GetLength(1); j++)
                {
                    Increment(octopusMap, i, j);
                }
            }

            // count flashes and reset the octopuses that flashed
            for (int i = 0; i < octopusMap.GetLength(0); i++)
            {
                for (int j = 0; j < octopusMap.GetLength(1); j++)
                {
                    if (octopusMap[i, j] > 9)
                    {
                        octopusMap[i, j] = 0;
                        flashes++;
                    }
                }
            }

            return flashes;
        }

        private static void PrintMap(int[,] octopusMap)
        {
            int counter = 0;

            foreach (int i in octopusMap)
            {
                counter++;

                Console.Write(i);
                
                if (counter > 0 && counter % octopusMap.GetLength(0) == 0)
                {
                    Console.Write(Environment.NewLine);
                }
            }

            Console.Write(Environment.NewLine);
        }

        private static void Increment(int[,] octopusMap, int i, int j)
        {
            bool flash = octopusMap[i, j]++ == 9;

            if (flash)
            {
                for (int k = i - 1; k <= i + 1; k++)
                {
                    for (int l = j - 1; l <= j + 1; l++)
                    {
                        if (!(k == i && l == j)
                            && k >= 0 && k < octopusMap.GetLength(0)
                            && l >= 0 && l < octopusMap.GetLength(1))
                        {
                            Increment(octopusMap, k, l);
                        }
                    }
                }
            }
        }
    }
}
