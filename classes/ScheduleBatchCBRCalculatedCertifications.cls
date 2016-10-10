global class ScheduleBatchCBRCalculatedCertifications implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        BatchCBRCalculatedCertifications processCert = new BatchCBRCalculatedCertifications(); 
        database.executebatch(processCert,200);
    }
}