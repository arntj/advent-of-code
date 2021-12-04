using Day04;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

(int firstScore, int lastScore) = BingoSubsystem.PlayBingo(data);
Console.WriteLine($"Result part one: {firstScore}");
Console.WriteLine($"Result part two: {lastScore}");
