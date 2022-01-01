namespace Day24
{
    public enum InstructionType
    {
        Inp, Add, Mul, Div, Mod, Eql
    }

    public interface IAluInstruction
    {
        InstructionType Type { get; }
        char A { get; }
    }

    public record InpInstruction(char A) : IAluInstruction
    {
        public InstructionType Type => InstructionType.Inp;
    }

    public record RegistryInstruction(InstructionType Type, char A, char B) : IAluInstruction { }
    public record LiteralInstruction(InstructionType Type, char A, int B) : IAluInstruction { }

    public static class Alu
    {
        public static IEnumerable<IAluInstruction> Parse(string[] inputs)
        {
            foreach (string line in inputs)
            {
                InstructionType type = line[..3] switch
                {
                    "inp" => InstructionType.Inp,
                    "add" => InstructionType.Add,
                    "mul" => InstructionType.Mul,
                    "div" => InstructionType.Div,
                    "mod" => InstructionType.Mod,
                    "eql" => InstructionType.Eql,
                    string instr => throw new NotImplementedException(instr)
                };

                char a = line[4];

                if (type == InstructionType.Inp)
                {
                    yield return new InpInstruction(a);
                    continue;
                }

                if (line[6] >= 'w' && line[6] <= 'z')
                {
                    yield return new RegistryInstruction(type, a, line[6]);
                }
                else
                {
                    yield return new LiteralInstruction(type, a, int.Parse(line[6..]));
                }
            }
        }

        public static int Execute(IEnumerable<IAluInstruction> instructions, int input, int initZ)
        {
            int[] registries = new[] { 0, 0, 0, initZ };

            foreach (var instruction in instructions)
            {
                if (instruction is InpInstruction inp)
                {
                    registries[inp.A - 'w'] = input;
                }
                else
                {
                    int b;

                    if (instruction is RegistryInstruction reg)
                    {
                        b = registries[reg.B - 'w'];
                    }
                    else if (instruction is LiteralInstruction lit)
                    {
                        b = lit.B;
                    }
                    else
                    {
                        throw new NotImplementedException();
                    }

                    switch (instruction.Type)
                    {
                        case InstructionType.Inp:
                            registries[instruction.A - 'w'] = b;
                            break;
                        case InstructionType.Add:
                            registries[instruction.A - 'w'] += b;
                            break;
                        case InstructionType.Mul:
                            registries[instruction.A - 'w'] *= b;
                            break;
                        case InstructionType.Div:
                            registries[instruction.A - 'w'] /= b;
                            break;
                        case InstructionType.Mod:
                            registries[instruction.A - 'w'] %= b;
                            break;
                        case InstructionType.Eql:
                            registries[instruction.A - 'w'] = registries[instruction.A - 'w'] == b ? 1 : 0;
                            break;
                    }
                }
            }

            return registries['z' - 'w'];
        }
    }
}
