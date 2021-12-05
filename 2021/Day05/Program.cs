using Day05;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

int highRiskZones = VentDetector.CountHighRiskZones(data, false);
int highRiskZonesDiagonals = VentDetector.CountHighRiskZones(data, true);
Console.WriteLine($"Result part one: {highRiskZones}");
Console.WriteLine($"Result part two: {highRiskZonesDiagonals}");
