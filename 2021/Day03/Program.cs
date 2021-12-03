using Day03;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

int powerConsumption = SubmarineDiagnostics.GetPowerConsumption(data);
int lifeSupportRating = SubmarineDiagnostics.GetLifeSupportRating(data);
Console.WriteLine($"Result part one: {powerConsumption}");
Console.WriteLine($"Result part two: {lifeSupportRating}");
