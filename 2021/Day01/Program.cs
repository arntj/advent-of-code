using Day01;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

Console.WriteLine($"Result part one: {DepthCounter.CountIncreases(data, 1)}");
Console.WriteLine($"Result part two: {DepthCounter.CountIncreases(data, 3)}");
