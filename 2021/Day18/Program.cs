using Day18;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

var numbers = SnailfishCalculator.ParseNumbers(data);
var sum = SnailfishCalculator.Add(numbers.ToArray());
var magnitude = SnailfishCalculator.Magnitude(sum);

int partOne = magnitude;
int partTwo = SnailfishCalculator.LargestMagnitudeSum(data);

Console.WriteLine($"Result part one: {partOne}");
Console.WriteLine($"Result part two: {partTwo}");
