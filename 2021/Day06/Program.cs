using Day06;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

long partOne = LanternfishSpawner.RunForDays(data[0], 80);
long partTwo = LanternfishSpawner.RunForDays(data[0], 256);
Console.WriteLine($"Result part one: {partOne}");
Console.WriteLine($"Result part two: {partTwo}");
