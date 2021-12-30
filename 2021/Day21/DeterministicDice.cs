namespace Day21
{
    public class DeterministicDice
    {
        private int value = 0;
        private int throws = 0;

        public int Throw()
        {
            int currResult = 0;

            for (int i = 0; i < 3; i++)
            {
                value++;

                if (value == 101)
                {
                    value = 1;
                }

                currResult += value;
                throws++;
            }            

            return currResult;
        }

        public int NumberOfThrows => throws;
    }
}
