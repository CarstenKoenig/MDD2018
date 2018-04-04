namespace ResultDemo
{
    public delegate bool Parser<tOut>(string input, out tOut output);
}