using Day07;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

int partOne = CrabFuelEstimator.EstimatePartOne(data[0]);
int partTwo = CrabFuelEstimator.EstimatePartTwo(data[0]);
Console.WriteLine($"Result part one: {partOne}");
Console.WriteLine($"Result part two: {partTwo}");
