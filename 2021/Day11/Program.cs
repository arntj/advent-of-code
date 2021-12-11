﻿using Day11;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

int partOne = OctopusFlashCounter.CountFlashes(data, 100);
int partTwo = OctopusFlashCounter.StepsBeforeAllFlash(data);
Console.WriteLine($"Result part one: {partOne}");
Console.WriteLine($"Result part two: {partTwo}");
